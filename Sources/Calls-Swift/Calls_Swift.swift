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
    
    // New Session
    public struct NewSessionRequest : Codable{
        public var sessionDescription : SessionDescription
        public init(sessionDescription: SessionDescription){
            self.sessionDescription = sessionDescription
        }
    }
    
    public struct NewSessionResponse : Codable{
        public var sessionDescription : SessionDescription
        public init(sessionDescription:SessionDescription){
            self.sessionDescription = sessionDescription
        }
    }
    
    public struct RenegotiateRequest : Codable{
        public var sessionDescription : SessionDescription
        public init(sessionDescription: SessionDescription){
            self.sessionDescription = sessionDescription
        }
    }
    
    public struct RenegotiateResponse : Encodable{
        public var sessionDescription : SessionDescription
        public init(sessionDescription:SessionDescription){
            self.sessionDescription = sessionDescription
        }
    }
    
    public struct SessionDescription: Codable{
        public var type : String
        public var sdp : String
        public init(type:String, sdp:String){
            self.type = type
            self.sdp = sdp
        }
    }
    
    // get Session
    public struct Track : Decodable{
        
        enum CodingKeys: String, CodingKey {
            case location
            case trackName
            case mid
            case status
            case sessionId
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            location = try container.decode(String.self, forKey: .location)
            if location == "local"{
                trackName = try container.decode(String.self, forKey: .trackName)
                mid = try container.decode(String.self, forKey: .mid)
                status = try container.decode(String.self, forKey: .status)
            }
            if location == "remote"{
                trackName = try container.decode(String.self, forKey: .trackName)
                sessionId = try container.decode(String.self, forKey: .sessionId)
                mid = try container.decode(String.self, forKey: .mid)
                status = try container.decode(String.self, forKey: .status)
            }
        }
        
        public var location : String?
        public var trackName : String?
        public var mid : String?
        public var status : String?
        public var sessionId : String?
    }

    public struct DataChannel : Decodable{
        
        enum CodingKeys: String, CodingKey {
            case location
            case dataChannelName
            case id
            case status
            case sessionId
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            location = try container.decode(String.self, forKey: .location)
            if location == "local"{
                dataChannelName = try container.decode(String.self, forKey: .dataChannelName)
                id = try container.decode(Int.self, forKey: .id)
                status = try container.decode(String.self, forKey: .status)
            }
            if location == "remote"{
                dataChannelName = try container.decode(String.self, forKey: .dataChannelName)
                id = try container.decode(Int.self, forKey: .id)
                status = try container.decode(String.self, forKey: .status)
                sessionId = try container.decode(String.self, forKey: .sessionId)
            }
        }
  
        public var location : String?
        public var sessionId : String?
        public var dataChannelName : String?
        public var id : Int = 0
        public var status : String?
    }

    
    public struct GetSessionStateResponse: Decodable{
        public var tracks: [Track]
        public var dataChannels: [DataChannel]
        
        enum CodingKeys: String, CodingKey {
            case tracks
            case dataChannels
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            tracks = try container.decode([Track].self, forKey: .tracks)
            dataChannels = try container.decode([DataChannel].self, forKey: .dataChannels)
        }
    }
    
    public struct DataChannelLocal : Encodable, Decodable{
        public var location : String = ""
        public var dataChannelName : String = ""
        public init(location:String, dataChannelName:String){
            self.location = location
            self.dataChannelName = dataChannelName
        }
    }
    
    public struct DataChannelRemote : Encodable, Decodable{
        public var location : String
        public var dataChannelName : String
        public var sessionId : String
        
        public init(location:String, dataChannelName:String, sessionId : String){
            self.location = location
            self.dataChannelName = dataChannelName
            self.sessionId = sessionId
        }
    }

    public struct DataChannelLocalResItem : Decodable{
        public var location : String
        public var dataChannelName : String
        public var id : Int

        public init(location:String, dataChannelName:String, id:Int){
            self.location = location
            self.dataChannelName = dataChannelName
            self.id = id
        }
    }
    
    public struct DataChannelRemoteItem  : Decodable{
        public var location : String
        public var dataChannelName : String
        public var sessionId : String?
        public var id : Int
 
        public init(location:String, dataChannelName:String, sessionId:String?, id:Int){
            self.location = location
            self.dataChannelName = dataChannelName
            self.sessionId = dataChannelName
            self.id = id
        }
    }
    
    public struct DataChannelLocalReq : Encodable{
        public var dataChannels : [DataChannelLocal]
        
        public init(dataChannels:[DataChannelLocal]){
            self.dataChannels = dataChannels
        }
    }
    
    public struct DataChannelRemoteReq : Encodable{
        public var dataChannels : [DataChannelRemote]
        
        public init(dataChannels:[DataChannelRemote]){
            self.dataChannels = dataChannels
        }
    }
    
    public struct DataChannelLocalRes : Decodable{
        public var dataChannels : [DataChannelLocalResItem]
        
        public init(dataChannels: [DataChannelLocalResItem]){
            self.dataChannels = dataChannels
        }
    }
    
    public struct DataChannelRemoteRes : Decodable{
        public var dataChannels : [DataChannelRemoteItem]
        
        public init(dataChannels: [DataChannelRemoteItem]){
            self.dataChannels = dataChannels
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
    
    public struct LocalTracksRes : Decodable{
        public var requiresImmediateRenegotiation : Bool
        public var sessionDescription : SessionDescription
        public var tracks : [LocalTrack]
        
        public init(requiresImmediateRenegotiation:Bool, sessionDescription:SessionDescription, tracks : [LocalTrack]){
            self.requiresImmediateRenegotiation = requiresImmediateRenegotiation
            self.sessionDescription = sessionDescription
            self.tracks = tracks
        }
    }
    
    public struct RemoteTracksRes : Decodable{
        public var requiresImmediateRenegotiation: Bool
        public var tracks : [RemoteTrack]
        
        public init(requiresImmediateRenegotiation:Bool, tracks : [RemoteTrack]){
            self.requiresImmediateRenegotiation = requiresImmediateRenegotiation
            self.tracks = tracks
        }
    }
    
    public struct NewTracksRes : Decodable{
        public var sessionId : String?
        public var trackName : String
        public var mid : String
        
        public init(sessionId : String, trackName :String, mid:String){
            self.sessionId = sessionId
            self.trackName = trackName
            self.mid = mid
        }
    }
    
    public struct CloseTrackObject : Codable{
        public var mid : String
        public init(mid : String){
            self.mid = mid
        }
    }

    public struct NewTracksResponse : Decodable{
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
        public var tracks: [CloseTrackObject]
        public var sessionDescription:SessionDescription
        public var force : Bool
        
        public init(tracks: [CloseTrackObject], sessionDescription:SessionDescription, force : Bool){
            self.tracks = tracks
            self.sessionDescription = sessionDescription
            self.force = force
        }
    }
    
    public struct CloseTracksResponse : Decodable{
        public var sessionDescription:SessionDescription?
        public var tracks: [CloseTrackObject]
        public var requiresImmediateRenegotiation : Bool
        
        public init(sessionDescription:SessionDescription?, requiresImmediateRenegotiation : Bool, tracks: [CloseTrackObject]){
            self.sessionDescription = sessionDescription
            self.requiresImmediateRenegotiation = requiresImmediateRenegotiation
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
        let desc = NewSessionRequest(sessionDescription:newReq)
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
                   
                    let desc = try self.decoder.decode(NewSessionRequest.self, from: responseData)
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
                let newTracksResponse = try self.decoder.decode(NewTracksResponse.self, from: responseData)
                return completion(newTracksResponse, "")
            } catch let error {
                return completion(nil,  error.localizedDescription)
            }
        }
        
        // perform the task
        task.resume()
    }
    
    public func renegotiate(sessionId:String, sessionDescription: SessionDescription, completion:  @escaping (_ error:String)->()) async{
        let session = URLSession.shared
        let url = URL(string: serverUrl + appId + "/sessions/" +  sessionId + "/renegotiate")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        
        let r = RenegotiateRequest(sessionDescription: sessionDescription)
        let data = convertJSONToData(item: r)
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
            return completion("OK")
        }
        
        // perform the task
        task.resume()
    }
    
    //   /apps/{appId}/sessions/{sessionId}/tracks/close:
    public func close(sessionId:String, closeTracksRequest:CloseTracksRequest, completion:  @escaping (_ closeTracksResponse:CloseTracksResponse?,  _ error:String)->()) async{
        let session = URLSession.shared
        let url = URL(string: serverUrl + appId + "/sessions/" + sessionId + "/tracks/close")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
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
            
            let str = String(decoding: responseData, as: UTF8.self)
            print(str)
            do {
                if let _ = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String: Any] {
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
    
   
    public func newDataChannel(sessionId:String, dataChannelReq: DataChannelLocalReq, completion:  @escaping (_ dataChannelRes: DataChannelLocalRes?, _ error:String?)->()) async{
        let session = URLSession.shared
        let url = URL(string: serverUrl + appId + "/sessions/" +  sessionId + "/datachannels/new")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        
        let data = convertJSONToData(item: dataChannelReq)
       
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
                let dataChannelRes = try self.decoder.decode(DataChannelLocalRes.self, from: responseData)
                return completion(dataChannelRes, "")
            } catch let error {
                return completion(nil,  error.localizedDescription)
            }
        }
        
        // perform the task
        task.resume()
    }
    
    public func newDataChannelRemote(sessionId:String, dataChannelReq: DataChannelRemoteReq, completion:  @escaping (_ dataChannelRes: DataChannelRemoteRes?, _ error:String?)->()) async{
        let session = URLSession.shared
        let url = URL(string: serverUrl + appId + "/sessions/" +  sessionId + "/datachannels/new")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        
        let data = convertJSONToData(item: dataChannelReq)
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
                let dataChannelRes = try self.decoder.decode(DataChannelRemoteRes.self, from: responseData)
                return completion(dataChannelRes, "")
            } catch let error {
                return completion(nil,  error.localizedDescription)
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
