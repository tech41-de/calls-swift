// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

struct NewReq :Encodable, Decodable{
    var sdp = ""
    var type = ""
}

struct NewDesc : Encodable, Decodable{
    var sessionDescription = NewReq()
}

public struct SessionDescription : Codable{
    var type = "offer"
    var sdp = ""
}

public struct SessionDescriptionOffer : Codable{
    var sessionDescription = SessionDescription()
}


public struct NewTrack : Codable{
    var sessionDescription = SessionDescription()
    var tracks = [Track]()
}

public struct NewTracksResponse : Codable{
    var requiresImmediateRenegotiation = false
    var sessionDescription = SessionDescription()
    var tracks = [Track]()
}

public struct Track : Codable{
    var location  = "local"
    var sessionId = ""
    var trackName = ""
    var mid = ""
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
   
    struct sid{
        var sessionId : String
    }
    

    
    public func Track(sessionId:String, newTrack: NewTrack, completion:  @escaping (_ tracks: NewTracksResponse?, _ error:String)->()) async{
        let session = URLSession.shared
        let url = URL(string: serverUrl + appId + "/sessions/" +  sessionId + "/tracks/new")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        
        let data = convertJSONToData(item: newTrack)
        request.httpBody = data
        
        let task =  session.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(nil, error.localizedDescription)
            }
            
            // ensure there is data returned
            guard let responseData = data else {
                return completion(nil,"Invalid Response received from the server")
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String: Any] {
                   
                    let newTracksResponse = try self.decoder.decode(NewTracksResponse.self, from: responseData)
                    return completion(newTracksResponse, "")
                } else {
                    return completion(nil, "data maybe corrupted or in wrong format")
                }
            } catch let error {
                return completion(nil,  error.localizedDescription)
            }
        }
        
        // perform the task
        task.resume()
    }
    
    public func newSession(sdp:String, completion:  @escaping (_ sessionId:String, _ sdp:String, _ error:String)->()) async{
        let session = URLSession.shared
        let url = URL(string: serverUrl + appId + "/sessions/new")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        
        let newReq = NewReq(sdp:sdp, type:"offer")
        let desc = NewDesc(sessionDescription:newReq)
        let data = convertJSONToData(item: desc)
        request.httpBody = data
        
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
