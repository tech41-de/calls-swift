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
    
    /*
     {"tracks":[{"location":"local","trackName":"a_900CF0AE-1DB4-44FA-9E00-39F25D74BFE3","mid":"1","status":"active"},{"location":"local","trackName":"v_7E7B5AC7-875D-48EB-B629-D8F2350E6342","mid":"2","status":"active"},{"location":"remote","sessionId":"199672c611810f350895672ea037f22b","trackName":"a_869256E3-45AB-4459-836C-0B8DDAF8EE20","mid":"5","status":"active"},{"location":"remote","sessionId":"199672c611810f350895672ea037f22b","trackName":"v_F70ADF9B-A7EA-4B42-A6D9-3EB67CF0A3AF","mid":"6","status":"active"}],"dataChannels":[{"location":"remote","sessionId":"199672c611810f350895672ea037f22b","dataChannelName":"d_EE60DA09-AF92-404A-81C1-B8A3DC83878F","id":1,"status":"initializing"},{"location":"local","dataChannelName":"d_6EB593D1-64C0-4EB5-A75F-DF94780751B1","id":2,"status":"initializing"}]}
     */

    public struct DataChannel : Decodable{
        
        enum CodingKeys: String, CodingKey {
                //Uncomment the following commentted lines, if your JSON formatted data comes with different keys like bellow
                case location       //= "user_name"
                case dataChannelName
                case id//= "user_message"
                case status
                case sessionId
            }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            location = try container.decode(String.self, forKey: .location)
            if location == "local"{
                dataChannelName = try container.decode(String.self, forKey: .dataChannelName)
                id = try container.decode(String.self, forKey: .id)
                status = try container.decode(String.self, forKey: .status)
            }
            if location == "remote"{
                dataChannelName = try container.decode(String.self, forKey: .dataChannelName)
                id = try container.decode(String.self, forKey: .id)
                status = try container.decode(String.self, forKey: .status)
                sessionId = try container.decode(String.self, forKey: .sessionId)
            }
        }
  
        public var location : String?
        public var sessionId : String?
        public var dataChannelName : String?
        public var id : String?
        public var status : String?
    }

    
    public struct GetSessionStateResponse: Decodable{
        public var tracks: [Track]
        public var dataChannels: [DataChannel]

        public init(tracks:[Track], dataChannels: [DataChannel]){
            self.tracks = tracks
            self.dataChannels = dataChannels
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
        public var location : String = ""
        public var dataChannelName : String = ""
        public var sessionId : String = ""
        
        public init(location:String, dataChannelName:String, sessionId : String){
            self.location = location
            self.dataChannelName = dataChannelName
            self.sessionId = sessionId
        }
    }

    public struct DataChannelLocalResItem : Encodable, Decodable{
        public var location : String = ""
        public var dataChannelName : String = ""

        public init(location:String, dataChannelName:String){
            self.location = location
            self.dataChannelName = dataChannelName
        }
    }
    
    public struct DataChannelRemoteItem : Encodable, Decodable{
        public var location : String = ""
        public var dataChannelName : String = ""
        public var sessionId : String = ""
 
        public init(location:String, dataChannelName:String, sessionId:String = "" ){
            self.location = location
            self.dataChannelName = dataChannelName
            self.sessionId = dataChannelName
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
    
    public struct ClosedTrack : Codable{
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
        public var tracks: [ClosedTrack]
        public var sessionDescription:SessionDescription
        public var force : Bool
        
        public init(tracks: [ClosedTrack], sessionDescription:SessionDescription, force : Bool){
            self.tracks = tracks
            self.sessionDescription = sessionDescription
            self.force = force
        }
    }
    
    public struct CloseTracksResponse : Decodable{
        public var sessionDescription:SessionDescription
        public var tracks: [ClosedTrack]
        public var requiresImmediateRenegotiation : Bool
        
        public init(sessionDescription:SessionDescription, requiresImmediateRenegotiation : Bool, tracks: [ClosedTrack]){
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
        let str = String(decoding: data!, as: UTF8.self)
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
    
    public func renegotiate(sessionId:String, sdp: NewDesc, completion:  @escaping (_ error:String)->()) async{
        let session = URLSession.shared
        let url = URL(string: serverUrl + appId + "/sessions/" +  sessionId + "/renegotiate")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        
        let data = convertJSONToData(item: sdp)
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
            
            guard let responseData = data else {
                return completion(nil,"Invalid Response received from the server")
            }
            
            let str = String(decoding: responseData, as: UTF8.self)
            print(str)
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
