//
//  File.swift
//
//
//  Created by Finer  Vine on 2021/11/27.
//

import NIOCore
import AsyncHTTPClient
import Foundation

/// 弹性 Engine 认证实现
public class OAuthComputeEngineAppEngineFlex: OAuthRefreshable {

    let httpClient: HTTPClient
    let tokenReqeust: HTTPClient.Request
    
    private let decoder = JSONDecoder()
    private let eventLoop: EventLoop
    
    public init(httpClient: HTTPClient, tokenReqeust: HTTPClient.Request, eventLoop: EventLoop) {
        self.httpClient = httpClient
        self.tokenReqeust = tokenReqeust
        self.eventLoop = eventLoop
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    public func refresh(_ refreshToken: String?) -> EventLoopFuture<OAuthAccessToken> {
        
        return httpClient.execute(request: tokenReqeust, eventLoop: .delegate(on: self.eventLoop)).flatMap { response in
            
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
    }
}
