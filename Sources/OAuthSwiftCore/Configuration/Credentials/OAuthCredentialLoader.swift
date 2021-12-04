//
//  File.swift
//  
//
//  Created by Finer  Vine on 2021/11/27.
//

import Foundation
import NIOCore
import AsyncHTTPClient

/// OAuth 凭据加载器
public class OAuthCredentialLoader {
    
    public static func getRefreshableToken(credentials: ApplicationDefaultCredentials,
                                           withConfig config: APIConfiguration,
                                           andClient client: HTTPClient,
                                           eventLoop: EventLoop) -> OAuthRefreshable {
        return OAuthApplicationDefault(credentials: credentials,
                                       httpClient: client,
                                       eventLoop: eventLoop)
    }
    
    /// 通用刷新Token
    public static func getCommonRefreshableToken(request: HTTPClient.Request,
                                                 andClient client: HTTPClient,
                                                 eventLoop: EventLoop) -> OAuthRefreshable {
        return OAuthComputeEngineAppEngineFlex(httpClient: client,
                                               tokenReqeust: request,
                                               eventLoop: eventLoop)
    }
}
