//
//  Controller.swift
//  RSession2
//
//  Created by mat on 8/11/24.
//

import SwiftUI

class Controller{
    static let shared = Controller()
    
    
    func OfferSDP(){
        WebRtcProxy.shared.mainViewController?.offerSDP()
    }

    func AcceptSDP(){
        WebRtcProxy.shared.mainViewController?.answerSDP()
    }
    
    func updateAudioInputDevice(name:String){
        guard let device = Model.shared.getAudioInDevice(name: name)else{
            return
        }
        Model.shared.audioInput = name
        UserDefaults.standard.set(name, forKey: "audioIn")
        AudioPermissionCheck.shared.setInputDevice(uid: device.uid)
        Model.shared.webRTCClient?.updateAudioInputDevice()
    }
    
    func updateAudioOutputDevice(name:String){
        guard let device = Model.shared.getAudioInDevice(name: name)else{
            return
        }
        Model.shared.audioOutput = name
        UserDefaults.standard.set(name, forKey: "audioOut")
        AudioPermissionCheck.shared.setOutputDevice(uid: device.uid)
        Model.shared.webRTCClient?.updateAudioOutputDevice()
    }
}
