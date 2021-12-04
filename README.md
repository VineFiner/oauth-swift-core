# oauth-swift-core

## This is the packaging of Oauth2.0


```
public protocol APIRequest: AnyObject {
    var refreshableToken: OAuthRefreshable { get } // Refresh actuator
     
    var httpClient: HTTPClient { get }
    var responseDecoder: JSONDecoder { get }
    
    var currentToken: OAuthAccessToken? { get set } // Token
    var tokenCreatedTime: Date? { get set } // createdTime
    
    /// As part of an API request this returns a valid OAuth token to use with any of the GoogleAPIs.
    /// - Parameter closure: The closure to be executed with the valid access token.
    /// - Returns: CodableModel
    func withToken<AnyCodableModel>(_ closure: @escaping (OAuthAccessToken) -> EventLoopFuture<AnyCodableModel>) -> EventLoopFuture<AnyCodableModel>
}
```
