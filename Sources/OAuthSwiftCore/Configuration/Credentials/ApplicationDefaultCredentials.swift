//
//  File.swift
//  
//
//  Created by Finer  Vine on 2021/11/29.
//

import Foundation

/// 从`~/.config/application_default_credentials.json` 加载凭据
public struct ApplicationDefaultCredentials: Codable {
    public let clientId: String
    public let clientSecret: String
    
    /// 刷新Token 的链接地址 eg:  https://TENANT.APP.DOMAIN/oauth2/token 
    public let tokenUri: String
    
    public init(clientId: String, clientSecret: String, tokenUri: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.tokenUri = tokenUri
    }
    
    public init(fromFilePath path: String) throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        if let contents = try String(contentsOfFile: path).data(using: .utf8) {
            self = try decoder.decode(ApplicationDefaultCredentials.self, from: contents)
        } else {
            throw CredentialLoadError.fileLoadError(path)
        }
    }

    public init(fromJsonString json: String) throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        if let data = json.data(using: .utf8) {
            self = try decoder.decode(ApplicationDefaultCredentials.self, from: data)
        } else {
            throw CredentialLoadError.jsonLoadError
        }
    }
}
