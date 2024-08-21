// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import LiveKitWebRTC
import OpenAPIURLSession
import OpenAPIRuntime

public class Calls{
    
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
   
    public func newSession() async{
        let client = Client(
            serverURL: URL(string: serverUrl)!,
            transport: transport,
            middlewares: [AuthenticationMiddleware(authorizationHeaderFieldValue: secret)]
        )

        let path = Operations.newSession.Input.Path(appId: appId)
        let input = Operations.newSession.Input(path: path)
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
}
