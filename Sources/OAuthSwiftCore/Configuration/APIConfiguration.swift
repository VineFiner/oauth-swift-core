//
//  File.swift
//
//
//  Created by Finer  Vine on 2021/11/27.
//

import Foundation

/// 每个 API 配置的协议。
public protocol APIConfiguration {
    /// 权限范围
    var scopes: [APIScope] { get }
    
}

public protocol APIScope {
    var value: String { get }
}
