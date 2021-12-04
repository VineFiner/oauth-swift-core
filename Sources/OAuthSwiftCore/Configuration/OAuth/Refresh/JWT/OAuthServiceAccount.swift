//
//  File.swift
//
//
//  Created by Finer  Vine on 2021/11/27.
//

import JWTKit
import NIOHTTP1
import NIOCore
import AsyncHTTPClient
import Foundation

/// 服务账户认证
public class OAuthServiceAccount: OAuthRefreshable {
    public let httpClient: HTTPClient
    public let credentials: ApplicationDefaultCredentials
    public let scope: String
    
    public let subscription : String?
    public let clientEmail: String
    public let privateKey: String
    
    private var eventLoop: EventLoop

    private let decoder = JSONDecoder()
    
    init(credentials: ApplicationDefaultCredentials,
         clientEmail: String,
         privateKey: String,
         scopes: [APIScope],
         subscription: String?,
         httpClient: HTTPClient,
         eventLoop: EventLoop) {
        
        self.credentials = credentials
        self.scope = scopes.map { $0.value }.joined(separator: " ")
        self.httpClient = httpClient
        self.eventLoop = eventLoop
        self.subscription = subscription
        self.clientEmail = clientEmail
        self.privateKey = privateKey
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    public func refresh(_ refreshToken: String?) -> EventLoopFuture<OAuthAccessToken> {
        do {
            let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
            let token = try generateJWT()
            let body: HTTPClient.Body = .string("grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=\(token)"
                                        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
            let request = try HTTPClient.Request(url: credentials.tokenUri, method: .POST, headers: headers, body: body)
            
            return httpClient.execute(request: request, eventLoop: .delegate(on: self.eventLoop)).flatMap { response in
                
                guard var byteBuffer = response.body,
                let responseData = byteBuffer.readData(length: byteBuffer.readableBytes),
                response.status == .ok else {
                    return self.eventLoop.makeFailedFuture(OauthRefreshError.noResponse(response.status))
                }
                
                do {
                    return self.eventLoop.makeSucceededFuture(try self.decoder.decode(OAuthAccessToken.self, from: responseData))
                } catch {
                    return self.eventLoop.makeFailedFuture(error)
                }
            }
            
        } catch {
            return self.eventLoop.makeFailedFuture(error)
        }
    }

    private func generateJWT() throws -> String {
        let payload = OAuthPayload(iss: IssuerClaim(value: clientEmail),
                                   scope: scope,
                                   aud: AudienceClaim(value: "\(credentials.tokenUri)"),
                                   exp: ExpirationClaim(value: Date().addingTimeInterval(3600)),
                                   iat: IssuedAtClaim(value: Date()), sub: subscription)
        let privateKey = try RSAKey.private(pem: privateKey.data(using: .utf8, allowLossyConversion: true) ?? Data())
        return try JWTSigner.rs256(key: privateKey).sign(payload)
    }
}
