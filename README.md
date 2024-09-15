# calls-swift
Calls Swift Library to access the Cloudflare Calls API - webRTC real-time serverless video, audio and data applications - unofficial

In production the library should be used on the server to not expose the Cloudflare Calls API Secret to the client.
Another option is touse a proxy server, that injects the Cloudflare Calls API Secret

To initalize the library:

Add package from:  https://github.com/tech41-de/calls-swift

in your code:

import Calls_Swift

configure(serverUrl:String, appId :String, secret:String)

Configuration
=============
serverurl for the API at the time of writing can be hardcoded to : "https://rtc.live.cloudflare.com/v1/apps/"
appId: your appID from Cloudflare Calls Dashboard - https://dash.cloudflare.com/
secret: your secret from Cloudflare Calls Dashboard- https://dash.cloudflare.com/


For an exmple visit https://github.com/tech41-de/calls-swift-testapp

Visit us at:
https://tech41.de
