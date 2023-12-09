//
//  ViewController.swift
//  Weboard
//
//  Created by mhc team on 2022/12/22.
//

import UIKit

class ViewController: UITabBarController {
    override func viewDidLoad() {
        print(UserAccountViewModel.sharedUserAccount.accountPath)
        if UserAccountViewModel.sharedUserAccount.userLogon == true {
            addChild(HomeTableViewController(), "首页", "tabbar_home")
        }
        addChild(UserViewController(), "我", "tabbar_profile")
    }
    private func addChild(_ vc: UIViewController,_ title: String, _ imageName: String) {
        vc.title = title
        vc.tabBarItem.image = UIImage(named: imageName)
        let nav = UINavigationController(rootViewController: vc)
        addChild(nav)
    }
}
