//
//  File.swift
//
//
//  Created by Finer  Vine on 2021/11/27.
//

import Foundation
import NIOCore
import AsyncHTTPClient

public protocol APIRequest: AnyObject {
    var refreshableToken: OAuthRefreshable { get }
    var httpClient: HTTPClient { get }
    var responseDecoder: JSONDecoder { get }
    var currentToken: OAuthAccessToken? { get set }
    var tokenCreatedTime: Date? { get set }
    
    /// 作为 API 请求的一部分，这会返回一个有效的 OAuth 令牌以用于任何 API。
    /// - 参数闭包：要使用有效访问令牌执行的闭包。
    /// - Returns: 编码模型
    func withToken<AnyCodableModel>(_ closure: @escaping (OAuthAccessToken) -> EventLoopFuture<AnyCodableModel>) -> EventLoopFuture<AnyCodableModel>
}

extension APIRequest {
    public func withToken<AnyCodableModel>(_ closure: @escaping (OAuthAccessToken) -> EventLoopFuture<AnyCodableModel>) -> EventLoopFuture<AnyCodableModel> {
        
        // 有值
        guard let token = currentToken else {
            return refreshableToken.refresh(nil).flatMap { newToken in
                self.currentToken = newToken
                self.tokenCreatedTime = Date()
                
                return closure(newToken)
            }
        }
        
        // 过期
        guard let created = tokenCreatedTime,
              refreshableToken.isFresh(token: token, created: created) else {
                  return refreshableToken.refresh(token.refresh_token).flatMap { newToken in
                      self.currentToken = newToken
                      self.tokenCreatedTime = Date()
                      
                      return closure(newToken)
                  }
              }
        // 有效
        return closure(token)
    }
}
