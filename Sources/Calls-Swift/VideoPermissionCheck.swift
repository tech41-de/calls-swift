//
//  VideoPermissionCheck.swift
//  RSession2
//
//  Created by mat on 8/11/24.
//

import Foundation
import AVFoundation

class VideoPermissionCheck{
    static let shared = VideoPermissionCheck()
    
    func setupVideo(){
        VideoPermissionCheck.findDevices()
       // STM.shared.exec(state: .Video)
    }
    
    func getDevice(name:String) ->AVCaptureDevice?{
        let devices = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        for device in devices.devices {
            if device.localizedName == name{
                return device
            }
        }
        return nil
    }
    
    static func findDevices() {
        let devices = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        
        Model.shared.videoDevices.removeAll()
        for device in devices.devices {
            Model.shared.videoDevices.append(ADevice(id:device.uniqueID, name:device.localizedName))
        }
        
        if (UserDefaults.standard.string(forKey: "videoIn") != nil){
            Model.shared.camera = UserDefaults.standard.string(forKey: "videoIn")!
        }else{
            Model.shared.camera = Model.shared.videoDevices[Model.shared.videoDevices.count - 1].name
        }
    }
        
}
