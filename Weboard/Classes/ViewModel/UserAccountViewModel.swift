//
//  UserAccountViewModel.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/10.
//

import Foundation
import SDWebImage
class UserAccountViewModel {
    var portraitURL: URL? {
        return URL(string: "http://tb.himg.baidu.com/sys/portraitn/item/"+(account?.portrait ?? ""))
    }
    static let sharedUserAccount = UserAccountViewModel()
    var account: UserAccount?
    var tokenAccount: TokenAccount?
    var userLogon: Bool {
        return accessToken != nil && !isExpired
    }
    var accessToken: String? {
        if !isExpired {
            return account?.access_token
        }
        return nil
    }
    var isExpired: Bool {
        if tokenAccount?.expiresDate?.compare(Date()) == ComparisonResult.orderedDescending {
            return false
        }
        return true
    }
    var accountPath: String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        return (path as NSString).appendingPathComponent("account.plist")
    }
    private init() {
        account = NSKeyedUnarchiver.unarchiveObject(withFile: accountPath) as? UserAccount
        print(account)
        if isExpired {
            print("已经过期")
            account = nil
        }
    }
}
extension UserAccountViewModel {
    func loadAccessToken(code: String, finished: @escaping (_ isSuccessed: Bool) -> ()) {
        NetworkTools.sharedTools.loadAccessToken(code: code) { Result,Error in
            if Error != nil {
                print("加载用户出错了")
                finished(false)
                return
            }
            guard let dict = Result as? [String: Any] else {
                print("格式错误")
                finished(false)
                return
            }
            self.tokenAccount = TokenAccount(dict: dict)
            self.account = UserAccount(dict: dict)
            self.tokenAccount?.expires_in = dict["expires_in"] as! TimeInterval
            self.loadUserInfo(account: self.account!,tokenAccount:self.tokenAccount!,finished: finished)
        }
    }
    private func loadUserInfo(account: UserAccount,tokenAccount: TokenAccount,finished: @escaping (_ isSuccessed: Bool) -> ()) {
        NetworkTools.sharedTools.loadUserInfo { Result,Error in
            if Error != nil {
                print("加载用户出错了")
                finished(false)
                return
            }
            guard let dict = Result as? [String: Any] else {
                print("格式错误")
                finished(false)
                return
            }
            ///设置图片String
            account.portrait = dict["portrait"] as? String
            ///设置名字String
            account.username = dict["username"] as? String
            ///设置刷新TOKENString
            account.refresh_token = tokenAccount.refresh_token
            
            account.birthday = dict["birthday"] as? String
            ///设置用户简介String
            account.openid = dict["openid"] as? String
            account.is_realname = dict["is_realname"] as? String
            ///创建文件
            NSKeyedArchiver.archiveRootObject(account, toFile: self.accountPath)
            //print(self.accountPath)
            finished(true)
        }
    }
}
