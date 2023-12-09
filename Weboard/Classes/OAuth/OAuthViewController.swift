//
//  OAuthTableViewController.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/6.
//

import UIKit

class OAuthViewController: UIViewController {
    private lazy var webView = UIWebView()
    @objc private func close() {
        dismiss(animated: true,completion: nil)
    }
    override func loadView() {
        view = webView
        webView.delegate = self
        title = "登录新浪微博"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(OAuthViewController.close))
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.loadRequest(URLRequest(url: NetworkTools.sharedTools.OAuthURL))
    }
}
extension OAuthViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        guard let url = request.url, url.host == "mhc-inc.github.io" else {
            return true
        }
        guard let query = url.query, query.hasPrefix("code=") else {
            print("取消授权")
            return false
        }
        let code = query.substring(from: "code=".endIndex)
        print("授权码是 "+code)
        UserAccountViewModel.sharedUserAccount.loadAccessToken(code: code) { (isSuccessed) -> () in
            if !isSuccessed {
                return
            }
            print("成功了")
            self.dismiss(animated: false) {
                NotificationCenter.default.post(name: .init(rawValue: WBSwitchRootViewControllerNotification), object: "welcome")
            }
        }
        return false
    }
}
