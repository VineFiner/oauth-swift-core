//
//  File.swift
//
//
//  Created by Finer  Vine on 2021/11/27.
//

import Foundation
import NIOFoundationCompat
import NIOCore

public protocol OAuthRefreshable {
    func isFresh(token: OAuthAccessToken, created: Date) -> Bool
    func refresh(_ refreshToken: String?) -> EventLoopFuture<OAuthAccessToken>
}

extension OAuthRefreshable {
    public func isFresh(token: OAuthAccessToken, created: Date) -> Bool {
        let now = Date()
        // 检查令牌是否将在接下来的 15 秒内到期。
        // 这为我们提供了一个缓冲区，并避免在发出请求时过于接近到期。
        let expiration = created.addingTimeInterval(TimeInterval(token.expires_in - 15))

        return expiration > now
    }
}
