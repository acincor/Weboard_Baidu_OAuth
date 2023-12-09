//
//  UserViewController.swift
//  Weboard
//
//  Created by mhc team on 2022/12/22.
//

import UIKit
import SDWebImage
import SnapKit

let StatusPictureViewItemMargin: CGFloat = 8
let StatusPictureCellId = "StatusPictureCellId"
class StatusPictureView:UICollectionView {
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = StatusPictureViewItemMargin
        layout.minimumInteritemSpacing = StatusPictureViewItemMargin
        super.init(frame: CGRectZero, collectionViewLayout: layout)
        delegate = self
        backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        dataSource = self
        register(StatusPictureViewCell.self, forCellWithReuseIdentifier: StatusPictureCellId)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class UserViewController: UIViewController {
    private var isRealnameLabel:String {
        return UserAccountViewModel.sharedUserAccount.account?.is_realname == "1" ? "用户真实姓名：": "用户姓名："
    }
    private var usernameLabel: String {
        return UserAccountViewModel.sharedUserAccount.account?.username ?? "用户未登录"
    }
    private var label: String {
        return isRealnameLabel+usernameLabel+elseLabel
    }
    private var elseLabel: String {
        return """
        
        用户生日：\(dateLabel! == "0000年00月00日" ? "未知" : dateLabel!)
        """
    }
    private lazy var Label: UILabel = UILabel(title:label,fontSize:19)
    private var dateLabel: Substring? {
        do {
            let year = UserAccountViewModel.sharedUserAccount.account?.birthday!.split(separator: try Regex("-"))[0] ?? Substring("0000")
            let month = UserAccountViewModel.sharedUserAccount.account?.birthday!.split(separator: try Regex("-"))[1] ?? Substring("00")
            let date = UserAccountViewModel.sharedUserAccount.account?.birthday!.split(separator: try Regex("-"))[2] ?? Substring("00")
            return year+"年"+month+"月"+date+"日"
        } catch {
            return "未登录"
        }
    }
    private lazy var iconView: StatusPictureView = {
        let iv = StatusPictureView()
        iv.layer.cornerRadius = 45
        iv.layer.masksToBounds = true
        return iv
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserAccountViewModel.sharedUserAccount.userLogon == false {
            print(NetworkTools.sharedTools.OAuthURL)
            present(UINavigationController(rootViewController: OAuthViewController()), animated: true)
        }
        view.addSubview(iconView)
        view.addSubview(Label)
        iconView.backgroundColor = .yellow
        let imageView = UIImageView(image: iconView.largeContentImage)
        imageView.sd_setImage(with: UserAccountViewModel.sharedUserAccount.portraitURL, placeholderImage: nil, options: [SDWebImageOptions.retryFailed,SDWebImageOptions.refreshCached])
        iconView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(view.snp.top).offset(50)
            make.width.equalTo(90)
            make.height.equalTo(90)
        }
        iconView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(view.snp.top).offset(50)
            make.width.equalTo(90)
            make.height.equalTo(90)
        }
        Label.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom)
        }
        Label.sizeToFit()
        // Do any additional setup after loading the view.
    }
}
class StatusPictureViewCell: UICollectionViewCell {
    var imageURL: URL? {
        didSet {
            iconView.sd_setImage(with: imageURL, placeholderImage: nil, options: [SDWebImageOptions.retryFailed,SDWebImageOptions.refreshCached])
            let ext = ((imageURL?.absoluteString ?? "") as NSString).pathExtension.lowercased()
            gifIconView.isHidden = (ext != "gif")
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        contentView.addSubview(iconView)
        iconView.addSubview(gifIconView)
        iconView.snp.makeConstraints { make in
            make.edges.equalTo(contentView.snp.edges)
            make.center.equalTo(contentView.snp.center)
        }
        gifIconView.snp.makeConstraints { make in
            make.right.equalTo(iconView.snp.right)
            make.bottom.equalTo(iconView.snp.bottom)
        }
    }
    private lazy var iconView: UIImageView = UIImageView()
    private lazy var gifIconView: UIImageView = UIImageView(imageName: "timeline_image_gif")
}
extension StatusPictureView:UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("单击照片\(indexPath)")
        //photoBrowserPresentFromRect(indexPath: indexPath)
        let userInfo = [WBStatusSelectedPhotoIndexPathKey: indexPath, WBStatusSelectedPhotoURLsKey: [UserAccountViewModel.sharedUserAccount.portraitURL]] as [String : Any]
        NotificationCenter.default.post(name: Notification.Name(WBStatusSelectedPhotoNotification), object: self, userInfo: userInfo)
        photoBrowserPresentToRect(indexPath: indexPath)
    }
}
extension StatusPictureView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatusPictureCellId, for: indexPath) as! StatusPictureViewCell
        cell.imageURL = UserAccountViewModel.sharedUserAccount.portraitURL
        return cell
    }
}
extension StatusPictureView: PhotoBrowserPresentDelegate {
    func photoBrowserPresentFromRect(indexPath: IndexPath) -> CGRect {
        let cell = self.cellForItem(at: indexPath)!
        let rect = self.convert(cell.frame, to: UIApplication.shared.keyWindow!)
        //let v = imageViewForPresent(indexPath: indexPath)
        //v.backgroundColor = .red
        //v.frame = rect
        //UIApplication.shared.keyWindow?.addSubview(v)
        return rect
    }
    func imageViewForPresent(indexPath: IndexPath) -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        if let url = UserAccountViewModel.sharedUserAccount.portraitURL {
            iv.sd_setImage(with: url)
        }
        return iv
    }
    func photoBrowserPresentToRect(indexPath: IndexPath) -> CGRect {
        guard let key = UserAccountViewModel.sharedUserAccount.portraitURL?.absoluteString else {
            return CGRectZero
        }
        guard let image = SDImageCache.shared.imageFromDiskCache(forKey: key) else {
            return CGRectZero
        }
        let w = UIScreen.main.bounds.width
        let h = image.size.height * w / image.size.width
        let screenHeight = UIScreen.main.bounds.height
        var y: CGFloat = 0
        if h < screenHeight {
            y = (screenHeight - h) * 0.5
        }
        let rect = CGRect(x: 0, y: y, width: w, height: h)
        return rect
    }
}
