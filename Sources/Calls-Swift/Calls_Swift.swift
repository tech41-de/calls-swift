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
    
    struct BodyNew{
        var value1: Components.Schemas.NewSessionRequest
        var value2: OpenAPIRuntime.OpenAPIValueContainer
    }
    
    public func newSession(sdp:String) async{
        let client = Client(
            serverURL: URL(string: serverUrl)!,
            transport: transport,
            middlewares: [AuthenticationMiddleware(authorizationHeaderFieldValue: "BEARER " + secret)]
        )

        let path = Operations.newSession.Input.Path(appId: appId)
        var req = Components.Schemas.NewSessionRequest()
        req.sessionDescription?.sdp = sdp
        req.sessionDescription?._type = .offer
        let p = Operations.newSession.Input.Body.jsonPayload(value1: req, value2: "")
        let d = Operations.newSession.Input.Body.json(p)
        let input = Operations.newSession.Input.init(path: path, body:d)
        let response = try? await client.newSession(input)
        switch response {
        case .created(let created):
            switch created.body {
            case .json(let created):
                print(created.value1)
                print(created.value2)
            }
        case .undocumented(statusCode: let statusCode, _):
            print("🥺 undocumented response: \(statusCode)")
        case .none:
            print("🥺 undocumented response: ")
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
