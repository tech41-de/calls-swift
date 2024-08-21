//
//  Config.swift
//  RSession
//
//  Created by mat on 8/7/24.
//

import SwiftUI

class Config{
    static let shared = Config()
    var retries = 5
    
    func load() {
        DispatchQueue.global(qos: .background).async {
            do{
                var url = ""
                switch(Global.ENV){
                case .Local:
                    url = Global.CONFIG_LOCAL
                    break
                    
                case .Dev:
                    url = Global.CONFIG_DEV
                    break
                    
                case .Test:
                    url = Global.CONFIG_TEST
                    break
                    
                case .Prod:
                    url = Global.CONFIG_PROD
                    break
                }
                
                if let url = URL(string: url) {
                    
                    let contents = try String(contentsOf: url)
                    let lines = contents.split(whereSeparator: \.isNewline)
                    self.config.removeAll()
                    for line in lines{
                        let v = line.components(separatedBy: "=")
                        self.config[v[0]] =  v[1]
                        print("Config \(v[0])=\(v[1])")
                    }
                    self.retries = 5
                    Model.shared.errorMsg = ""
                    Model.shared.showError = false
                    Model.shared.hasConfig = true
                    STM.shared.exec(state: States.Keys)
                }
            }catch{
                print(error)
                if self.retries > 0{
                    self.retries -= 1
                    sleep(5)
                    
                    STM.shared.exec(state: States.Config)
                    print("retrying to get config file \(self.retries) left")
                    return
                }
                Model.shared.errorMsg = ErrorMsg.NO_INTERNET
                Model.shared.showError = true
                self.retries  = 5
                STM.shared.exec(state: States.Config)
            }
        }
    }
    
    func get(key:String)->String{
        if config[key] != nil{
            return config[key]!
        }
        return ""
    }
    
    func get(key:ConfigKeys)->String{
        if config[key.rawValue] != nil{
            return config[key.rawValue]!
        }
        return ""
    }
    
    var config = [String:String]()
}
