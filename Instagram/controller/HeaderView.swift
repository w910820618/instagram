//
//  HeaderView.swift
//  Instagram
//
//  Created by 吴洲洋 on 2021/9/19.
//

import UIKit

class HeaderView: UICollectionReusableView {
    @IBOutlet var avaImg: UIImageView!
    @IBOutlet var posts: UILabel!
    @IBOutlet var followers: UILabel!
    @IBOutlet var followings: UILabel!
    @IBOutlet var postTitle: UILabel!
    @IBOutlet var followersTitle: UILabel!
    @IBOutlet var followingsTitle: UILabel!
    @IBOutlet var button: UIButton!
    @IBOutlet var fullnameLbl: UILabel!
    @IBOutlet var webTxt: UILabel!
    @IBOutlet var bioLbl: UILabel!

    @IBAction func followBtn_clicked(_ sender: UIButton) {
        let title = button.title(for: .normal)
        let user = guestArray.last
        if title == "关 注" {
            guard let user = user else { return }
            AVUser.current()!.follow(user.objectId!, andCallback: { (success: Bool, error: Error?) in
                if success {
                    self.button.setTitle("√ 已关注", for: .normal)
                    self.button.backgroundColor = .green
                } else {
                    print(error?.localizedDescription)
                }
            })
        } else {
            guard let user = user else { return }
            AVUser.current()!.unfollow(user.objectId!, andCallback: { (success: Bool, error: Error?) in
                if success {
                    self.button.setTitle("关 注", for: .normal)
                    self.button.backgroundColor = .lightGray
                } else {
                    print(error?.localizedDescription)
                }
            })
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // 对齐
        let width = UIScreen.main.bounds.width
        avaImg.frame = CGRect(x: width / 16, y: width / 16, width: width / 4, height: width / 4)
        // 对三个统计数据进行布局
        posts.frame = CGRect(x: width / 2.5, y: avaImg.frame.origin.y, width: 50, height: 30)
        followers.frame = CGRect(x: width / 1.6, y: avaImg.frame.origin.y, width: 50, height: 30)
        followings.frame = CGRect(x: width / 1.2, y: avaImg.frame.origin.y, width: 50, height: 30)
        // 设置三个统计数据Title的布局
        postTitle.center = CGPoint(x: posts.center.x, y: posts.center.y + 20)
        followersTitle.center = CGPoint(x: followers.center.x, y: followers.center.y + 20)
        followingsTitle.center = CGPoint(x: followings.center.x, y: followings.center.y + 20)
        // 设置按钮的布局
        button.frame = CGRect(x: postTitle.frame.origin.x, y: postTitle.center.y + 20, width: width - postTitle.frame.origin.x - 10, height: 30)
        fullnameLbl.frame = CGRect(x: avaImg.frame.origin.x, y: avaImg.frame.origin.y + avaImg.frame.height, width: width - 30, height: 30)
        webTxt.frame = CGRect(x: avaImg.frame.origin.x - 5, y: fullnameLbl.frame.origin.y + 15, width: width - 30, height: 30)
        bioLbl.frame = CGRect(x: avaImg.frame.origin.x, y: webTxt.frame.origin.y + 30, width: width - 30, height: 30)
    }
}
