//
//  NetworkTools.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/8.
//

import Foundation
import AFNetworking

class NetworkTools: AFHTTPSessionManager {
    static let sharedTools: NetworkTools = {
        let tools = NetworkTools(baseURL: nil)
        tools.responseSerializer.acceptableContentTypes?.insert("text/plain")
        return tools
    }()
    private var tokenDict: [String: Any]? {
        if let token = UserAccountViewModel.sharedUserAccount.accessToken {
            return ["access_token": token]
        }
        return nil
    }
    enum HMRequestMethod: String {
        case GET = "GET"
        case POST = "POST"
    }
    let appKey = "Fhk1m14tI3fGiV23xG73Oyl3"
    let appSecret = "6bBjwubPK3NX9yDm34y5ymcFMIKGgvHc"
    let redirectUrl = "https://mhc-inc.github.io/"
    
    lazy var OAuthURL: URL = URL(string:"https://openapi.baidu.com/oauth/2.0/authorize?response_type=code&client_id=\(appKey)&redirect_uri=\(redirectUrl)&scope=basic,super_msg,netdisk,pcs_doc,pcs_video&display=mobile&login_type=sms")!
    typealias HMRequstCallBack = (_ Result: Any?, _ Error: Error?) -> ()
}
extension NetworkTools {
    func request(_ method: HMRequestMethod, _ URLString: String, _ parameters: [String: Any]?, finished: @escaping HMRequstCallBack) {
        let success = {(task: URLSessionDataTask?, Result: Any?) -> Void in
            finished(Result,nil)
        }
        let failure = {(task: URLSessionDataTask?, Error: Error) -> Void in
            finished(nil,Error)
        }
        if method == HMRequestMethod.GET {
            get(URLString, parameters: parameters,headers: nil,progress: nil,success:success,failure: failure)
        } else {
            post(URLString, parameters: parameters, headers: nil, progress: nil,
            success: success,failure: failure)

        }
    }
    func loadAccessToken(code: String, finished: @escaping HMRequstCallBack) {
        let urlString = "https://openapi.baidu.com/oauth/2.0/token"
        let params = ["client_id":appKey,
                      "client_secret": appSecret,
                      "grant_type":"authorization_code",
                      "code":code,
                      "redirect_uri": redirectUrl]
        request(.POST, urlString, params, finished: finished)
    }
}
extension NetworkTools {
    func loadUserInfo(finished: @escaping HMRequstCallBack) {
        guard let params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token为空"]))
            return
        }
        let urlString = "https://openapi.baidu.com/rest/2.0/passport/users/getInfo"
        request(.GET, urlString, params, finished: finished)
    }
    func expireSession(_ finished: @escaping HMRequstCallBack) {
        guard var params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token为空"]))
            return
        }
        let urlString = "https://openapi.baidu.com/rest/2.0/passport/auth/expireSession"
        request(.GET, urlString, params, finished: finished)
    }
}
