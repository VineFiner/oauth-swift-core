//
//  File.swift
//
//
//  Created by Finer  Vine on 2021/11/27.
//

import JWTKit

/// 用于请求 OAuth 令牌以对 OAuth API 进行 API 调用的有效负载。
public struct OAuthPayload: JWTPayload {
    
    /// 发行者：eg 服务帐号的电子邮件地址。
    var iss: IssuerClaim
    
    /// 应用程序请求的权限的空格分隔列表。
    var scope: String
    
    /// 断言的预期目标的描述符。 发出访问令牌请求时，此值始终为
    var aud: AudienceClaim
    
    /// 断言的到期时间，指定为自 UTC 时间 1970 年 1 月 1 日 00:00:00 以来的秒数。该值在发布时间后最长为 1 小时。
    var exp: ExpirationClaim
    
    /// 发出断言的时间，指定为自 1970 年 1 月 1 日 00:00:00 UTC 以来的秒数。
    var iat: IssuedAtClaim
    
    /// 用于指定要从服务帐户访问的域上的帐户
    var sub: String?
    
    public func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}
