//
//  WebRtcProxy.swift
//  RSession
//
//  Created by mat on 8/5/24.
//

import LiveKitWebRTC
import Foundation
import AVFoundation

class WebRtcProxy{
    static let shared = WebRtcProxy()
    
    func getAudioOutputDeviceName() ->String{
        var deviceId = AudioDeviceID(0);
        var deviceSize = UInt32(MemoryLayout.size(ofValue: deviceId));
        var address = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDefaultOutputDevice, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMaster);
        var err = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &deviceSize, &deviceId);

        if ( err == 0) {
            // change the query property and use previously fetched details
            address.mSelector = kAudioDevicePropertyDeviceNameCFString;
            var deviceName = "" as CFString;
            deviceSize = UInt32(MemoryLayout.size(ofValue: deviceName));
            err = AudioObjectGetPropertyData( deviceId, &address, 0, nil, &deviceSize, &deviceName);
            if (err == 0) {
                print("### current default mic:: \(deviceName) ");
                return deviceName as String
            } else {
               return ""
            }
        } else {
           return ""
        }
    }
    
    func getAudioInputDeviceName() ->String{
        var deviceId = AudioDeviceID(0);
        var deviceSize = UInt32(MemoryLayout.size(ofValue: deviceId));
        var address = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDefaultInputDevice, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMaster);
        var err = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &deviceSize, &deviceId);

        if ( err == 0) {
            // change the query property and use previously fetched details
            address.mSelector = kAudioDevicePropertyDeviceNameCFString;
            var deviceName = "" as CFString;
            deviceSize = UInt32(MemoryLayout.size(ofValue: deviceName));
            err = AudioObjectGetPropertyData( deviceId, &address, 0, nil, &deviceSize, &deviceName);
            if (err == 0) {
                print("### current default mic:: \(deviceName) ");
                return deviceName as String
            } else {
               return ""
            }
        } else {
           return ""
        }
    }
    
    var mainViewController : MainController?
    
    func start(){
        print("WebRtcProxy starts")

        Model.shared.webRTCClient = WebRTCClient(iceServers:  [Config.shared.get(key: ConfigKeys.stunClient)])
        mainViewController = MainController(webRTCClient: Model.shared.webRTCClient!)
        mainViewController!.bindViews()
        STM.shared.exec(state: .Connect)
    }
}
