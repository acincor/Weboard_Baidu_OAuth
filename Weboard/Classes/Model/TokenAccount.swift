//
//  expiresInAccount.swift
//  Weboard
//
//  Created by mhc team on 2022/12/23.
//

import UIKit

class TokenAccount: NSObject {
    /// 用于调用access_token，接口获取授权后的access token
    @objc var refresh_token: String?
    init(dict: [String: Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    /// access_token的生命周期，单位是秒数
    @objc var expires_in: TimeInterval = 0 {
        didSet {
            expiresDate = Date(timeIntervalSinceNow: expires_in)
        }
    }
    @objc var expiresDate: Date?
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    
    override var description: String {
        let keys = ["expires_in","refresh_token","expiresDate"]
        return dictionaryWithValues(forKeys: keys).description
    }
}
