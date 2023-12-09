//
//  HomeTableViewController.swift
//  Weboard
//
//  Created by mhc team on 2022/12/22.
//

import UIKit
import SVProgressHUD
let BDStatusCellId = "BDStatusCellId"
class HomeTableViewController: UITableViewController, UIAlertViewDelegate, UITextViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //注册可重用cell
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: BDStatusCellId)
        //设置代理
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        NotificationCenter.default.addObserver(forName: Notification.Name(WBStatusSelectedPhotoNotification), object: nil, queue: nil) {[weak self] n in
            guard let indexPath = n.userInfo?[WBStatusSelectedPhotoIndexPathKey] as? IndexPath else {
                return
            }
            guard let urls = n.userInfo?[WBStatusSelectedPhotoURLsKey] as? [URL] else {
                return
            }
            guard let cell = n.object as? PhotoBrowserPresentDelegate else {
                return
            }
            let vc = PhotoBrowserViewController(urls: urls, indexPath: indexPath)
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = self?.photoBrowserAnimator
            self?.photoBrowserAnimator.setDelegateParams(present: cell, using: indexPath, dimissDelegate: vc)
            self?.present(vc, animated: true,completion: nil)
        }
    }
    private lazy var photoBrowserAnimator: PhotoBrowserAnimator = PhotoBrowserAnimator()
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return UserViewController().preferredContentSize.height
        }
        return 40
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BDStatusCellId,for: indexPath)
        if indexPath.row == 1 {
            cell.contentView.addSubview(UserViewController().view)
        } else {
            let textView = UITextView()
            print(UserAccountViewModel.sharedUserAccount.tokenAccount!)
            textView.attributedText = NSAttributedString(string: "\(UserAccountViewModel.sharedUserAccount.account!.username!)登录将过期于\( UserAccountViewModel.sharedUserAccount.tokenAccount!.expiresDate!)")
            cell.contentView.insertSubview(textView, aboveSubview: cell)
            textView.frame = cell.frame
            let text = UITextView()
            text.text = "退出登录"
            text.textColor = .red
            cell.contentView.addSubview(text)
            text.snp.makeConstraints { make in
                make.left.equalTo(textView.snp.right)
            }
            text.delegate = self
            textView.delegate = self
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        let alert = UIAlertView(title: "退出登录", message: "是否退出登录", delegate: self, cancelButtonTitle: "取消")
        alert.addButton(withTitle: "确认")
        alert.cancelButtonIndex = 0
        alert.delegate = self
        alert.show()
        view.addSubview(alert)
        return false
    }
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            NetworkTools.sharedTools.expireSession { Result, Error in
                if Error != nil {
                    print("退出")
                    return
                }
                do {
                    try FileManager.default.removeItem(at: URL(filePath: UserAccountViewModel.sharedUserAccount.accountPath))
                    UserAccountViewModel.sharedUserAccount.account?.access_token = nil
                    UserAccountViewModel.sharedUserAccount.tokenAccount?.expires_in = 0
                    UserAccountViewModel.sharedUserAccount.tokenAccount?.expiresDate = Date.now
                    print(UserAccountViewModel.sharedUserAccount.tokenAccount!)
                    self.modalPresentationStyle = .fullScreen
                    self.present(OAuthViewController(), animated: true)
                } catch {
                    SVProgressHUD.showInfo(withStatus: "退登失败")
                }
            }
        }
    }
    
}
