// The Swift Programming Language
// https://docs.swift.org/swift-book


import Foundation

public class Calls{
    
    public struct NewReq :Encodable, Decodable{
        public var sdp : String
        public var type : String
        
        public init(sdp:String, type : String){
            self.sdp = sdp
            self.type = type
        }
    }

    public struct NewDesc : Encodable, Decodable{
        public var sessionDescription : NewReq
        
        public init(sessionDescription:NewReq){
            self.sessionDescription = sessionDescription
        }
    }

    public struct SessionDescription : Codable{
        public var type :String
        public var sdp :String
        
        public init(sdp :String, type:String){
            self.sdp = sdp
            self.type = type
        }
    }

    public struct SessionDescriptionOffer : Codable{
        public var sessionDescription : SessionDescription
        
        public init(sessionDescription:SessionDescription){
            self.sessionDescription = sessionDescription
        }
    }

    public struct NewTracksRequest : Codable{
        public var local_tracks:LocalTracks
        public var remote_tracks:RemoteTracks

        public init(local_tracks:LocalTracks, remote_tracks:RemoteTracks ){
            self.local_tracks = local_tracks
            self.remote_tracks = remote_tracks
        }
    }
    
    public struct LocalTracks : Codable{
        public var sessionDescription : SessionDescription
        public var tracks : [LocalTrack]
        
        public init(sessionDescription:SessionDescription, tracks : [LocalTrack]){
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
    
    public struct RemoteTracks : Codable{
        public var tracks : [RemoteTrack]
        public init(tracks : [RemoteTrack]){
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

    public struct NewTracksResponse : Codable{
        public var local_tracks:LocalTracksRes
        public var remote_tracks:RemoteTracksRes

        public init(local_tracks:LocalTracksRes, remote_tracks:RemoteTracksRes ){
            self.local_tracks = local_tracks
            self.remote_tracks = remote_tracks
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
    
    public func newTracks(sessionId:String, newTrack: NewTracksRequest, completion:  @escaping (_ tracks: NewTracksResponse?, _ error:String)->()) async{
        let session = URLSession.shared
        let url = URL(string: serverUrl + appId + "/sessions/" +  sessionId + "/tracks/new")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        
        let data = convertJSONToData(item: newTrack)
        let str = String(decoding: data!, as: UTF8.self)
        print(str)
        
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
                let newTracksResponse = try self.decoder.decode(NewTracksResponse.self, from: responseData)
                return completion(newTracksResponse, "")
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
