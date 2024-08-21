// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import LiveKitWebRTC
import OpenAPIURLSession
import OpenAPIRuntime

public class Calls{
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    let transport: ClientTransport = URLSessionTransport()
    
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
    

    public func newSession(sdp:String, completion: (_ sessionId:String, _ sdp:String, _ error:String)->()) async{
        let client = Client(
            serverURL: URL(string: serverUrl)!,
            transport: transport,
            middlewares: [AuthenticationMiddleware(authorizationHeaderFieldValue: "BEARER " + secret)]
        )

        let path = Operations.newSession.Input.Path(appId: appId)
        var req = Components.Schemas.NewSessionRequest()
        req.sessionDescription?.sdp = sdp
        req.sessionDescription?._type = .offer
        var c = try? OpenAPIValueContainer()
        c?.value = "not set"
        let data = try? encoder.encode(req)
        let body = HTTPBody(data!) as? Operations.newSession.Input.Body
        let response = try? await client.newSession(
            path:path,
            body: body
        )
        switch response {
        case .created(let created):
            switch created.body {
            case .json(let created):
                print(created.value1)
                print(created.value2)
                completion("some", "spd", "")
            }
        case .undocumented(statusCode: let statusCode, _):
            print("🥺 undocumented response: \(statusCode)")
            completion("", "", "statusCode \(statusCode)")
        case .none:
            print("🥺 undocumented response: ")
            completion("", "", "unknown")
        }
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
