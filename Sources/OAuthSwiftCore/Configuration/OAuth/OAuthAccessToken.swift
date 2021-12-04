//
//  File.swift
//
//
//  Created by Finer  Vine on 2021/11/27.
//

import Foundation

/// 从授权服务器返回的访问令牌，用于对 API 进行身份验证。
public struct OAuthAccessToken: Codable {
    public let access_token: String
    public let refresh_token: String
    public let token_type: String
    public let expires_in: Int
    
}
