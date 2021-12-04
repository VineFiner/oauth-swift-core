//
//  File.swift
//
//
//  Created by Finer  Vine on 2021/11/27.
//

import Foundation
import NIOCore
import AsyncHTTPClient
import NIOHTTP1

/// 默认认证
public class OAuthApplicationDefault: OAuthRefreshable {
    let httpClient: HTTPClient
    let credentials: ApplicationDefaultCredentials
    
    private let decoder = JSONDecoder()
    private let eventLoop: EventLoop
    
    public init(credentials: ApplicationDefaultCredentials, httpClient: HTTPClient, eventLoop: EventLoop) {
        self.credentials = credentials
        self.httpClient = httpClient
        self.eventLoop = eventLoop
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    public func refresh(_ refreshToken: String?) -> EventLoopFuture<OAuthAccessToken> {
        do {
            let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
            
            let body: HTTPClient.Body = .string("client_id=\(credentials.clientId)&client_secret=\(credentials.clientSecret)&refresh_token=\(refreshToken ?? "")&grant_type=refresh_token")
            
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
}
