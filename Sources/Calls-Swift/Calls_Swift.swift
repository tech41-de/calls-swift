// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import LiveKitWebRTC

struct NewReq :Encodable, Decodable{
    var sdp = ""
    var type = ""
}

struct NewDesc : Encodable, Decodable{
    var sessionDescription = NewReq()
}

public class Calls{
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    var serverUrl = "https://rtc.live.cloudflare.com/v1"
    var appId = ""
    var secret = ""
    
    public init(){
        
    }
    
    public func configure(serverUrl:String, appId :String, secret:String){
        self.serverUrl = serverUrl
        self.appId = appId
        self.secret = secret
    }
   
    public struct SessionDescription : Codable{
        var type = "offer"
        var sdp = ""
    }
    
    public struct SessionDescriptionOffer : Codable{
        var sessionDescription = SessionDescription()
    }
    

    struct sid{
        var sessionId : String
    }
    
    public func newSession(sdp:String, completion:  @escaping (_ sessionId:String, _ sdp:String, _ error:String)->()) async{
        let session = URLSession.shared
        let url = URL(string: serverUrl + appId + "/sessions/new")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        
        var msg = SessionDescriptionOffer()
        msg.sessionDescription.sdp = sdp
        msg.sessionDescription.type = "ofder"
        request.httpBody = try? JSONSerialization.data(withJSONObject: msg)
        
        let task =  session.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion("","",error.localizedDescription)
            }
            
            // ensure there is data returned
            guard let responseData = data else {
                return completion("","","Invalid Response received from the server")
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String: Any] {
                    let desc = try self.decoder.decode(NewDesc.self, from: responseData)
                    let sessionIdStr =  jsonResponse["sessionId"]
                    return completion(sessionIdStr as! String, desc.sessionDescription.sdp,"")
                } else {
                    return completion("","", "data maybe corrupted or in wrong format")
                }
            } catch let error {
                return completion("","", error.localizedDescription)
            }
        }
        
        // perform the task
        task.resume()
    }

    
    func convertJSONToData<T: Encodable>(item: T) -> Data? {
        do {
            let encodedJSON = try JSONEncoder().encode(item)
            return encodedJSON
        } catch {
            return nil
        }
    }
}
