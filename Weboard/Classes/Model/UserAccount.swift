//
//  UserAccount.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/10.
//

import UIKit

/// 用户账户模型
class UserAccount: NSObject, NSCoding {
    /// 用于调用access_token，接口获取授权后的access token
    @objc var access_token: String?
    @objc var portrait: String?
    @objc var username: String?
    @objc var scope: String?
    @objc var birthday: String?
    @objc var is_realname: String?
    @objc var openid: String?
    init(dict: [String: Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    @objc var refresh_token: String?
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    
    override var description: String {
        let keys = ["access_token","portrait","username","scope","refresh_token","birthday","is_realname","openid"]
        return dictionaryWithValues(forKeys: keys).description
    }
    
    // MARK: - `键值`归档和解档
    /// 归档 - 在把当前对象保存到磁盘前，将对象编码成二进制数据
    ///
    /// - parameter coder: 编码器
    func encode(with coder: NSCoder) {
        coder.encode(openid,forKey: "openid")
        coder.encode(is_realname, forKey: "is_realname")
        coder.encode(birthday,forKey: "birthday")
        coder.encode(refresh_token,forKey: "refresh_token")
        coder.encode(scope, forKey: "scope")
        coder.encode(username, forKey: "username")
        coder.encode(portrait, forKey: "portrait")
        coder.encode(access_token, forKey: "access_token")
    }
    
    ///解档 - 从磁盘加载二进制文件，转换成对象时调用
    /// - parameter coder: 解码器
    ///
    /// - returns: 当前对象
    required init?(coder: NSCoder) {
        openid = coder.decodeObject(forKey: "openid") as? String
        is_realname = coder.decodeObject(forKey: "is_realname") as? String
        birthday = coder.decodeObject(forKey: "birthday") as? String
        refresh_token = coder.decodeObject(forKey: "refresh_token") as? String
        scope = coder.decodeObject(forKey: "scope") as? String
        portrait = coder.decodeObject(forKey: "portrait") as? String
        username = coder.decodeObject(forKey: "username") as? String
        access_token = coder.decodeObject(forKey: "access_token") as? String
    }
    func saveUserAccount() {
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        path = (path as NSString).appendingPathComponent("account.plist")
        print(path)
        NSKeyedArchiver.archiveRootObject(self, toFile: path)
    }
}
