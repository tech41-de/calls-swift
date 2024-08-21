//
//  STM.swift
//  RSession2
//
//  Created by mat on 8/11/24.
//

import SwiftUI

public class STM{
    private init(){}
    
    public static let shared = STM()
    
    func exec(state:States){
        DispatchQueue.main.async {
            print("STM handles: \(state)")
            switch(state){
                
            case .Config:
                Config.shared.load()
                break
                
            case .Keys:

                break
                
            case .Hello:
              //  ApiClient.shared.hello()
                break
                
            case .Logon:
              //  ApiClient.shared.logon()
                break
                
            case .AudioPermission:
                AudioPermissionCheck.shared.setupAudio()
                break
            case .Audio:
               
                break
                
            case .VideoPermission:
                VideoPermissionCheck.shared.setupVideo()
                break
                
            case .Video:
                WebRtcProxy.shared.start()
                break
                
            case .TUN:
                break
                
            case .Room:
                break
                
            case .Connect:

                break
                
            case .Wait:
                break
                
            case .Offer:
                break
                
            case .Answer:
                break
                
            case .WaitAnswer:
                break
                
            case .Ice:
                break
                
            case .IceWait:
                break
                
            case .Peer:
                break
                
            case .Stream:
                break
            }
        }
    }
}
