//
//  MainController.swift
//  RSession
//
//  Created by mat on 8/7/24.
//


import AVFoundation
import LiveKitWebRTC
import SwiftUI

extension MainController: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: LKRTCIceCandidate) {
        print("discovered local candidate")
        self.localCandidateCount += 1
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        switch state {
        case .connected, .completed:
            Model.shared.isConnected = true
        case .disconnected:
            Model.shared.isConnected = false
        case .failed, .closed:
            Model.shared.isConnected = false
        case .new, .checking, .count:
            Model.shared.isConnected = false
        @unknown default:
            Model.shared.isConnected = false
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        DispatchQueue.main.async {
            let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"
            print(message)
        }
    }
}



class MainController {
    private let webRTCClient: WebRTCClient

    private var signalingConnected: Bool = false {
        didSet {
            DispatchQueue.main.async {
                if self.signalingConnected {
                    Model.shared.signalIndicator = "✅"
                }
                else {
                    Model.shared.signalIndicator =  "❌"
                }
            }
        }
    }
    
    private var hasLocalSdp: Bool = false {
        didSet {
            DispatchQueue.main.async {
                Model.shared.hasSDPLocal = self.hasLocalSdp ? "✅" : "❌"
            }
        }
    }
    
    private var localCandidateCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                print("localCandidateCount \(self.localCandidateCount)")
            }
        }
    }
    
    private var hasRemoteSdp: Bool = false {
        didSet {
            DispatchQueue.main.async {
                Model.shared.hasSDPRemote = self.hasRemoteSdp ? "✅" : "❌"
            }
        }
    }
    
    private var remoteCandidateCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                print("remoteCandidateCount \(self.remoteCandidateCount)")
            }
        }
    }
    
    private var speakerOn: Bool = false {
        didSet {
            //let title = "Speaker: \(self.speakerOn ? "On" : "Off" )"
        }
    }
    
    private var mute: Bool = false {
        didSet {
           // let title = "Mute: \(self.mute ? "on" : "off")"
        }
    }
    
    func offerSDP() {
        self.webRTCClient.offer { (sdp) in
            self.hasLocalSdp = true
           // CloudflareApi.shared.newsSession(sdp: sdp)
        }
    }
    
    func answerSDP() {
        self.webRTCClient.answer { (localSdp) in
            self.hasLocalSdp = true
        }
    }
    
    init(webRTCClient: WebRTCClient) {
        self.webRTCClient = webRTCClient
        self.signalingConnected = false
        self.hasLocalSdp = false
        self.hasRemoteSdp = false
        self.localCandidateCount = 0
        self.remoteCandidateCount = 0
        self.speakerOn = true
        self.webRTCClient.delegate = self
    
    }
    
    func bindViews(){
        let remoteRenderer = LKRTCMTLNSVideoView(frame: CGRect(x:0,y:0, width:150, height:150))
       // Model.shared.youView.addSubview(remoteRenderer)
        
        let localRenderer = LKRTCMTLNSVideoView(frame: CGRect(x:0,y:0, width:150, height:150))
       // Model.shared.myView.addSubview(localRenderer)
        
       self.webRTCClient.startCaptureLocalVideo(renderer: localRenderer)
       self.webRTCClient.renderRemoteVideo(to: remoteRenderer)
    }
}
