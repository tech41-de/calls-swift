// The Swift Programming Language
// https://docs.swift.org/swift-book


import Foundation

public class Calls{
    var serverUrl = "https://rtc.live.cloudflare.com/v1"
    var appId = ""
    var secret = ""
    
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    public init(){
        
    }
    
    public func configure(serverUrl:String, appId :String, secret:String){
        self.serverUrl = serverUrl
        self.appId = appId
        self.secret = secret
    }
    
    public struct NewDesc : Encodable, Decodable{
        public var sessionDescription : SessionDescription
        
        public init(sessionDescription:SessionDescription){
            self.sessionDescription = sessionDescription
        }
    }

    public struct SessionDescription : Codable{
        public var type :String
        public var sdp :String
       
        public init(type:String, sdp :String){
            self.type = type
            self.sdp = sdp
           
        }
    }

    public struct SessionDescriptionOffer : Codable{
        public var sessionDescription : SessionDescription
        
        public init(sessionDescription:SessionDescription){
            self.sessionDescription = sessionDescription
        }
    }

    public struct NewTracksRemote : Codable{
        public var tracks:[RemoteTrack]
        
        public init(tracks:[RemoteTrack] ){
            self.tracks = tracks
        }
    }
    
    public struct NewTracksLocal : Codable{
        public var sessionDescription : SessionDescription
        public var tracks:[LocalTrack]
        
        public init(sessionDescription: SessionDescription, tracks:[LocalTrack] ){
            self.sessionDescription = sessionDescription
            self.tracks = tracks
        }
    }
    
    public struct LocalTracksRes : Codable{
        public var requiresImmediateRenegotiation : Bool
        public var sessionDescription : SessionDescription
        public var tracks : [LocalTrack]
        
        public init(requiresImmediateRenegotiation:Bool, sessionDescription:SessionDescription, tracks : [LocalTrack]){
            self.requiresImmediateRenegotiation = requiresImmediateRenegotiation
            self.sessionDescription = sessionDescription
            self.tracks = tracks
        }
    }
    
    public struct RemoteTracksRes : Codable{
        public var requiresImmediateRenegotiation: Bool
        public var tracks : [RemoteTrack]
        
        public init(requiresImmediateRenegotiation:Bool, tracks : [RemoteTrack]){
            self.requiresImmediateRenegotiation = requiresImmediateRenegotiation
            self.tracks = tracks
        }
    }
    
    public struct NewTracksRes : Codable{
        public var sessionId : String?
        public var trackName : String
        public var mid : String
        
        public init(sessionId : String, trackName :String, mid:String){
            self.sessionId = sessionId
            self.trackName = trackName
            self.mid = mid
        }
    }

    public struct NewTracksResponse : Codable{
        public var requiresImmediateRenegotiation : Bool
        public var tracks : [NewTracksRes]
        public var sessionDescription : SessionDescription
        
        public init(requiresImmediateRenegotiation:Bool, tracks:[NewTracksRes], sessionDescription : SessionDescription ){
            self.requiresImmediateRenegotiation = requiresImmediateRenegotiation
            self.tracks = tracks
            self.sessionDescription = sessionDescription
        }
    }

    public struct LocalTrack : Codable{
        public var location :String
        public var mid : String
        public var trackName : String
       
        public init(location:String, mid : String, trackName :String){
            self.location = location
            self.mid = mid
            self.trackName = trackName
        }
    }
    
    public struct RemoteTrack : Codable{
        public var location :String
        public var sessionId : String
        public var trackName : String
        
        public init(location:String, sessionId : String, trackName :String){
            self.location = location
            self.sessionId = sessionId
            self.trackName = trackName
        }
    }
    
    public struct CloseTracksRequest : Codable{
        var sessionDescription:SessionDescription
        var tracks: LocalTrack
        var force : Bool
        
        public init(sessionDescription:SessionDescription, tracks: LocalTrack, force : Bool){
            self.sessionDescription = sessionDescription
            self.tracks = tracks
            self.force = force
        }
    }
    
    public struct CloseTracksResponse : Codable{
        var sessionDescription:SessionDescription
        var tracks: LocalTrack
        var requiresImmediateRenegotiation : Bool
        
        public init(sessionDescription:SessionDescription, requiresImmediateRenegotiation : Bool, tracks: LocalTrack){
            self.sessionDescription = sessionDescription
            self.requiresImmediateRenegotiation = requiresImmediateRenegotiation
            self.tracks = tracks
        }
    }
    
    public struct GetSessionStateResponse: Codable{
        var tracks: LocalTrack
        
        public init(tracks:LocalTrack){
            self.tracks = tracks
        }
    }
    
    public func newSession(sdp:String, completion:  @escaping (_ sessionId:String, _ sdp:String, _ error:String)->()) async{
        let session = URLSession.shared
        let url = URL(string: serverUrl + appId + "/sessions/new")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        
        let newReq = SessionDescription(type:"offer", sdp:sdp)
        let desc = NewDesc(sessionDescription:newReq)
        let data = convertJSONToData(item: desc)
        request.httpBody = data
        
        let task =  session.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 201{
                    return completion("", "", String(httpResponse.statusCode))
                }
            }
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
    
    public func newLocalTracks(sessionId:String, newTracks: NewTracksLocal, completion:  @escaping (_ tracks: NewTracksResponse?, _ error:String)->()) async{
        let session = URLSession.shared
        let url = URL(string: serverUrl + appId + "/sessions/" +  sessionId + "/tracks/new")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        
        let data = convertJSONToData(item: newTracks)
        let str = String(decoding: data!, as: UTF8.self)
        print(str)
        
        request.httpBody = data
        
        let task =  session.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200{
                    return completion(nil,  String(httpResponse.statusCode))
                }
            }
            
            if let error = error {
                return completion(nil, error.localizedDescription)
            }
            
            // ensure there is data returned
            guard let responseData = data else {
                return completion(nil,"Invalid Response received from the server")
            }
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String: Any] {
                    print(jsonResponse)
                }
                let newTracksResponse = try self.decoder.decode(NewTracksResponse.self, from: responseData)
                return completion(newTracksResponse, "")
            } catch let error {
                return completion(nil,  error.localizedDescription)
            }
        }
        
        // perform the task
        task.resume()
    }
    
    public func newTracks(sessionId:String, newTracksRemote: NewTracksRemote, completion:  @escaping (_ tracks: NewTracksResponse?, _ error:String?)->()) async{
        let session = URLSession.shared
        let url = URL(string: serverUrl + appId + "/sessions/" +  sessionId + "/tracks/new")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        
        let data = convertJSONToData(item: newTracksRemote)
        let str = String(decoding: data!, as: UTF8.self)
        print(str)
        
        request.httpBody = data
        
        let task =  session.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200{
                    return completion(nil,  String(httpResponse.statusCode))
                }
            }
            if let error = error {
                return completion(nil, error.localizedDescription)
            }
            
            // ensure there is data returned
            guard let responseData = data else {
                return completion(nil,"Invalid Response received from the server")
            }
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String: Any] {
                    print(jsonResponse)
                }
                let newTracksResponse = try self.decoder.decode(NewTracksResponse.self, from: responseData)
                return completion(newTracksResponse, "")
            } catch let error {
                return completion(nil,  error.localizedDescription)
            }
        }
        
        // perform the task
        task.resume()
    }
    
    public func renegotiate(sessionId:String, sdp: NewDesc, completion:  @escaping (_ error:String)->()) async{
        let session = URLSession.shared
        let url = URL(string: serverUrl + appId + "/sessions/" +  sessionId + "/renegotiate")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        
        let data = convertJSONToData(item: sdp)
        let str = String(decoding: data!, as: UTF8.self)
        print(str)
        
        request.httpBody = data
        
        let task =  session.dataTask(with: request) { data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200{
                    return completion( String(httpResponse.statusCode))
                }
            }
            
            if let error = error {
                return completion( error.localizedDescription)
            }
            
            // ensure there is data returned
            guard let responseData = data else {
                return completion("Invalid Response received from the server")
            }
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String: Any] {
                    print(jsonResponse)
                }
                return completion("OK")
            } catch let error {
                return completion(error.localizedDescription)
            }
        }
        
        // perform the task
        task.resume()
    }
    
    public func close(sessionId:String, closeTracksRequest:CloseTracksRequest, completion:  @escaping (_ closeTracksResponse:CloseTracksResponse?,  _ error:String)->()) async{
        let session = URLSession.shared
        let url = URL(string: serverUrl + appId + "/sessions" + sessionId + "/tracks/close")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")

        let data = convertJSONToData(item: closeTracksRequest)
        request.httpBody = data
        
        let task =  session.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200{
                    return completion(nil, String(httpResponse.statusCode))
                }
            }
            if let error = error {
                return completion(nil,error.localizedDescription)
            }
            
            // ensure there is data returned
            guard let responseData = data else {
                return completion(nil,"Invalid Response received from the server")
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String: Any] {
                    let res = try self.decoder.decode(CloseTracksResponse.self, from: responseData)
                    return completion(res,"")
                } else {
                    return completion(nil, "data maybe corrupted or in wrong format")
                }
            } catch let error {
                return completion(nil, error.localizedDescription)
            }
        }
        
        // perform the task
        task.resume()
    }
    
    
    public func getSession(sessionId:String, completion:  @escaping (_ getSessionStateResponse:GetSessionStateResponse?,  _ error:String)->()) async{
        let session = URLSession.shared
        let url = URL(string: serverUrl + appId + "/sessions/" + sessionId)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")

        let task =  session.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200{
                    return completion(nil, String(httpResponse.statusCode))
                }
            }
            if let error = error {
                return completion(nil,error.localizedDescription)
            }
            
            // ensure there is data returned
            guard let responseData = data else {
                return completion(nil,"Invalid Response received from the server")
            }
            
            do {
                let res = try self.decoder.decode(GetSessionStateResponse.self, from: responseData)
                return completion(res, "")
            } catch let error {
                return completion(nil, error.localizedDescription)
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
