# calls-swift
Calls Swift Library to access the Cloudflare Calls API - webRTC real-time serverless video, audio and data applications - unofficial

In production the library should be used on the server to not expose the Cloudflare Calls API secret to the client.
Another option is to use a proxy server, that injects the Cloudflare Calls API secret into the header.

To use the library:

Add package from:  https://github.com/tech41-de/calls-swift

in your code:

import Calls_Swift

configure(serverUrl:String, appId :String, secret:String)


Configuration
=============
serverurl for the API at the time of writing can be hardcoded to : "https://rtc.live.cloudflare.com/v1/apps/"
appId: your appID from Cloudflare Calls Dashboard - https://dash.cloudflare.com/
secret: your secret from Cloudflare Calls Dashboard- https://dash.cloudflare.com/


An example for MAC, Mac Catalyst and iOS can be found at: https://github.com/tech41-de/calls-swift-testapp


Visit us at:
https://tech41.de
