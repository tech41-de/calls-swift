//
//  Model.swift
//  RSession
//
//  Created by Mathias Dietrich on 30.07.24.
//

import SwiftUI
import LiveKitWebRTC

public enum ConfigKeys : String{
    case api
    case stunIp
    case stunPort
    case stunClient
    case tun
    case solana
    case signal
}

public enum Environments{
    case Local
    case Dev
    case Test
    case Prod
}

public enum States{
    case Config  // gets the static config file based on Environment Local, Dev, Test, Prod from Github

    case Keys // if no keys asks user if he has Solana keys or creates Nickname and Public and Private Keypair

    case Hello  // sends Public Key to API and retrieves nonce

    case Logon  // signs nonce with private key and sends to API, retrieves JWT Token

    case AudioPermission

    case Audio // shows main screen, populates Audio dropdown, selects default Audio device

    case VideoPermission

    case Video // populatesvCameracDropdown and selects Video device and starts rendering Me Video

    case TUN // creates SDP

    case Room // if user did not enter Room waits for Room

    case Connect // Connects to Signaling Server

    case Wait // waits for an Offer 1 Second

    case Offer // sends SDP Offer

    case Answer // sends SDP Answer

    case WaitAnswer // waits for

    case Ice // sends Ice

    case IceWait // waits for Ice Message

    case Peer // starts Streaming

    case Stream  // starts receiving Stream
}

public struct StunDetails{
    var type :String = ""
    var familiy: String = ""
    var address : String = ""
    var port : Int = 0
}

public struct ADevice{
    var id = ""
    var name = ""
    var uid :UInt32 = 0
}

public class Model : ObservableObject{
    
    static let shared = Model()
    
    @Published var stunText : String = "❌"
    @Published var natText : String = "❌"

    @Published var camera = ""
    @Published var audioInput = ""
    @Published var audioOutput = ""
    
    @Published var stunDetails = StunDetails()
    @Published var localIp = "❌"
    @Published var udpListenPort = 0
    @Published var apiVersion = ""
    @Published var videoFrame:LKRTCVideoFrame?
    @Published var videoFrameMe:LKRTCVideoFrame?
    @Published var signalIndicator = "❌"
    @Published var hasSDPLocal = "❌"
    @Published var hasSDPRemote = "❌"
    @Published var isConnected = false
    @Published var youView = LKRTCMTLNSVideoView()
    @Published var myView = LKRTCMTLNSVideoView()

    @Published var jwtToken = ""
    @Published var isLoggedOn = false
    
    @Published var errorMsg = ""
    @Published var showError = false
    
    @Published var hasConfig = false
    
    @Published var audioInDevices = [ADevice]()
    @Published var audioOutDevices = [ADevice]()
    @Published var videoDevices = [ADevice]()
    
    @Published var audioInputDefaultDevice : AudioDeviceID? // the devices pre app Start
    @Published var audioOutputDefaultDevice : AudioDeviceID?
    
    @Published var sessionId = ""
    @Published var sessionIdRemote = ""
    
    var trackIdLocalVideo =  ""
    var trackIdLocalAudio =  ""
    
    var midLocalVideo =  ""
    var midLocalAudio =  ""
    
    var trackIdVideoRemote =  UUID().uuidString
    var localSDP : LKRTCSessionDescription?

    var webRTCClient : WebRTCClient?
    
    func getAudioInDevice(name:String)->ADevice?{
        for d in audioInDevices{
            if d.name == name{
                return d
            }
        }
        return nil
    }
    
    func getAudioOutDevice(name:String)->ADevice?{
        for d in audioOutDevices{
            if d.name == name{
                return d
            }
        }
        return nil
    }
}
