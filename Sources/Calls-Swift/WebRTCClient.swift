//
//  File.swift
//  
//
//  Created by mat on 8/21/24.
//

import Foundation

import Foundation
import AVFoundation
import LiveKitWebRTC

protocol WebRTCClientDelegate: AnyObject {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: LKRTCIceCandidate)
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState)
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data)
}

final class WebRTCClient: NSObject {
    
    private static let factory: LKRTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let videoEncoderFactory = LKRTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = LKRTCDefaultVideoDecoderFactory()
        return LKRTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
    }()
    
    weak var delegate: WebRTCClientDelegate?
    private let peerConnection: LKRTCPeerConnection
    private let audioQueue = DispatchQueue(label: "audio")
    private let mediaConstrains = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
 kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]
    private var videoCapturer: LKRTCVideoCapturer?
    private var localVideoTrack: LKRTCVideoTrack?
    private var remoteVideoTrack: LKRTCVideoTrack?
    private var localDataChannel: LKRTCDataChannel?
    private var remoteDataChannel: LKRTCDataChannel?
    
    private var rtcRtpSender  : LKRTCRtpSender?

    @available(*, unavailable)
    override init() {
        fatalError("WebRTCClient:init is unavailable")
    }
    
    /*
    func defaultICEServer() -> [RTCICEServer] {

      var iceServers = [RTCICEServer]()
      let defaultSTUNServerURL = URL(string: Config.defaultSTUNServerUrl)
      let defaultTURNServerURL = URL(string: Config.defaultTURNServerUrl)
      let stunServ = RTCICEServer(uri: defaultSTUNServerURL, username: "", password: "")
      let turnServ = RTCICEServer(uri: defaultTURNServerURL, username: "admin", password: "admin")
      iceServers.append(stunServ!)
      iceServers.append(turnServ!)

      return iceServers
    }
     */
    
    required init(iceServers: [String]) {
        let config = LKRTCConfiguration()
        config.iceServers = [LKRTCIceServer(urlStrings: iceServers)]
        
        // Unified plan is more superior than planB
        config.sdpSemantics = .unifiedPlan
        
        // gatherContinually will let WebRTC to listen to any network changes and send any new candidates to the other client
        config.continualGatheringPolicy = .gatherContinually
        
        // Define media constraints. DtlsSrtpKeyAgreement is required to be true to be able to connect with web browsers.
        let constraints = LKRTCMediaConstraints(mandatoryConstraints: nil,optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue])
        
        guard let peerConnection = WebRTCClient.factory.peerConnection(with: config, constraints: constraints, delegate: nil) else {
            fatalError("Could not create new RTCPeerConnection")
        }
        
        self.peerConnection = peerConnection
        
        super.init()
        self.createMediaSenders()
        self.peerConnection.delegate = self
    }
    
    // MARK: Signaling
    func offer(completion: @escaping (_ sdp: LKRTCSessionDescription) -> Void) {
        let constrains = LKRTCMediaConstraints(mandatoryConstraints: self.mediaConstrains, optionalConstraints: nil)
        self.peerConnection.offer(for: constrains) { (sdp, error) in
            guard let sdp = sdp else {return}
            self.peerConnection.setLocalDescription(sdp, completionHandler: { (error) in
                completion(sdp)
            })
        }
    }
    
    func answer(completion: @escaping (_ sdp: LKRTCSessionDescription) -> Void)  {
        let constrains = LKRTCMediaConstraints(mandatoryConstraints: self.mediaConstrains, optionalConstraints: nil)
        self.peerConnection.answer(for: constrains) { (sdp, error) in
            guard let sdp = sdp else {return}
            self.peerConnection.setLocalDescription(sdp, completionHandler: { (error) in
                completion(sdp)
            })
        }
    }
    
    func set(remoteSdp: LKRTCSessionDescription, completion: @escaping (Error?) -> ()) {
        self.peerConnection.setRemoteDescription(remoteSdp, completionHandler: completion)
    }
    
    func set(remoteCandidate: LKRTCIceCandidate, completion: @escaping (Error?) -> ()) {
        self.peerConnection.add(remoteCandidate)
    }
    
    // MARK: Media
    func startCaptureLocalVideo(renderer: LKRTCVideoRenderer) {
       guard let capturer = self.videoCapturer as? LKRTCCameraVideoCapturer else {
            return
        }
        let camera = VideoPermissionCheck.shared.getDevice(name: Model.shared.camera)
        guard let frontCamera = camera,
            let format = (LKRTCCameraVideoCapturer.supportedFormats(for: frontCamera).sorted { (f1, f2) -> Bool in
                let width1 = CMVideoFormatDescriptionGetDimensions(f1.formatDescription).width
                let width2 = CMVideoFormatDescriptionGetDimensions(f2.formatDescription).width
                return width1 < width2
            }).last,
        
            // choose highest fps
            let fps = (format.videoSupportedFrameRateRanges.sorted { return $0.maxFrameRate < $1.maxFrameRate }.last) else {
            return
        }
        print("Capturing local Camera with \(fps) \(format)")
        capturer.startCapture(with: frontCamera, format: format, fps: Int(fps.maxFrameRate))
        self.localVideoTrack?.add(renderer)
    }
    
    func renderRemoteVideo(to renderer: LKRTCVideoRenderer) {
        self.remoteVideoTrack?.add(renderer)
    }
    
    func updateAudioInputDevice(){
        let streamId = "stream"
        self.peerConnection.removeTrack(rtcRtpSender!)
        let newAudioTrack = createAudioTrack()
        rtcRtpSender =  self.peerConnection.add(newAudioTrack, streamIds: [streamId])
        Controller.shared.OfferSDP()
    }
    
    func updateAudioOutputDevice(){
        let streamId = "stream"
        self.peerConnection.removeTrack(rtcRtpSender!)
        let newAudioTrack = createAudioTrack()
        rtcRtpSender = self.peerConnection.add(newAudioTrack, streamIds: [streamId])
        Controller.shared.OfferSDP()
    }
    
    private func createMediaSenders() {
        let streamId = "stream"
        
        // Audio
        let audioTrack = self.createAudioTrack()
        rtcRtpSender = self.peerConnection.add(audioTrack, streamIds: [streamId])
        Model.shared.trackIdLocalAudio =  audioTrack.trackId
        
        // Video
        let videoTrack = self.createVideoTrack(trackId: "video0")
        let videoTrackRemote = self.createVideoTrack(trackId: Model.shared.trackIdVideoRemote)
        
        self.localVideoTrack = videoTrack
        Model.shared.trackIdLocalVideo =  self.localVideoTrack!.trackId

        
        self.peerConnection.add(videoTrack, streamIds: [streamId])
        self.remoteVideoTrack = self.peerConnection.transceivers.first { $0.mediaType == .video }?.receiver.track as? LKRTCVideoTrack

        
        // Data
        if let dataChannel = createDataChannel() {
            dataChannel.delegate = self
            self.localDataChannel = dataChannel
        }
    }
    
    struct RTCPair{
        var key : String
        var value : String
    }
    
    private func createAudioTrack() -> LKRTCAudioTrack {
        let device = Model.shared.getAudioInDevice(name:Model.shared.audioInput)
        
        // TODO this is not working
        let audioConstrains = LKRTCMediaConstraints(mandatoryConstraints:["audio":"{'deviceId': '\(device!.uid)'}"], optionalConstraints: nil)
        let audioSource = WebRTCClient.factory.audioSource(with: audioConstrains)
        audioSource.volume = 1.0
        let audioTrack = WebRTCClient.factory.audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
    }
    
    func createVideoTrack(trackId:String) -> LKRTCVideoTrack {
        let videoSource = WebRTCClient.factory.videoSource()
        self.videoCapturer = LKRTCCameraVideoCapturer(delegate: videoSource)
        return WebRTCClient.factory.videoTrack(with: videoSource, trackId: trackId)
    }

    // MARK: Data Channels
    private func createDataChannel() -> LKRTCDataChannel? {
        let config = LKRTCDataChannelConfiguration()
        guard let dataChannel = self.peerConnection.dataChannel(forLabel: "WebRTCData", configuration: config) else {
            debugPrint("Warning: Couldn't create data channel.")
            return nil
        }
        return dataChannel
    }
    
    func sendData(_ data: Data) {
        let buffer = LKRTCDataBuffer(data: data, isBinary: true)
        self.remoteDataChannel?.sendData(buffer)
    }
}

// ##############################################################################
// Delegate
// ##############################################################################
extension WebRTCClient: LKRTCPeerConnectionDelegate {
    
    func peerConnection(_ peerConnection: LKRTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        debugPrint("peerConnection new signaling state: \(stateChanged)")
    }
    
    func peerConnection(_ peerConnection: LKRTCPeerConnection, didAdd stream: LKRTCMediaStream) {
        debugPrint("peerConnection did add stream")
    }
    
    func peerConnection(_ peerConnection: LKRTCPeerConnection, didRemove stream: LKRTCMediaStream) {
        debugPrint("peerConnection did remove stream")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: LKRTCPeerConnection) {
        debugPrint("peerConnection should negotiate")
    }
    
    func peerConnection(_ peerConnection: LKRTCPeerConnection, didChange newState: RTCIceConnectionState) {
        debugPrint("peerConnection new connection state: \(newState)")
        self.delegate?.webRTCClient(self, didChangeConnectionState: newState)
    }
    
    func peerConnection(_ peerConnection: LKRTCPeerConnection, didChange newState: RTCIceGatheringState) {
        debugPrint("peerConnection new gathering state: \(newState)")
    }
    
    func peerConnection(_ peerConnection: LKRTCPeerConnection, didGenerate candidate: LKRTCIceCandidate) {
        self.delegate?.webRTCClient(self, didDiscoverLocalCandidate: candidate)
    }
    
    func peerConnection(_ peerConnection: LKRTCPeerConnection, didRemove candidates: [LKRTCIceCandidate]) {
        debugPrint("peerConnection did remove candidate(s)")
    }
    
    func peerConnection(_ peerConnection: LKRTCPeerConnection, didOpen dataChannel: LKRTCDataChannel) {
        debugPrint("peerConnection did open data channel")
        self.remoteDataChannel = dataChannel
    }
}
extension WebRTCClient {
    private func setTrackEnabled<T: LKRTCMediaStreamTrack>(_ type: T.Type, isEnabled: Bool) {
        peerConnection.transceivers
            .compactMap { return $0.sender.track as? T }
            .forEach { $0.isEnabled = isEnabled }
    }
}

// MARK: - Video control
extension WebRTCClient {
    func hideVideo() {
        self.setVideoEnabled(false)
    }
    func showVideo() {
        self.setVideoEnabled(true)
    }
    private func setVideoEnabled(_ isEnabled: Bool) {
        setTrackEnabled(LKRTCVideoTrack.self, isEnabled: isEnabled)
    }
}
// MARK:- Audio control
extension WebRTCClient {
    func muteAudio() {
        self.setAudioEnabled(false)
    }
    
    func unmuteAudio() {
        self.setAudioEnabled(true)
    }

    private func setAudioEnabled(_ isEnabled: Bool) {
        setTrackEnabled(LKRTCAudioTrack.self, isEnabled: isEnabled)
    }
}

extension WebRTCClient: LKRTCDataChannelDelegate {
    func dataChannelDidChangeState(_ dataChannel: LKRTCDataChannel) {
        debugPrint("dataChannel did change state: \(dataChannel.readyState)")
    }
    
    func dataChannel(_ dataChannel: LKRTCDataChannel, didReceiveMessageWith buffer: LKRTCDataBuffer) {
        self.delegate?.webRTCClient(self, didReceiveData: buffer.data)
    }
}
