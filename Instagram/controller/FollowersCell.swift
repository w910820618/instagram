//
//  FollowersCell.swift
//  Instagram
//
//  Created by 吴洲洋 on 2021/9/20.
//

import UIKit

class FollowersCell: UITableViewCell {
    @IBOutlet var avaImg: UIImageView!

    @IBOutlet var usernameLbl: UILabel!

    @IBOutlet var followBtn: UIButton!

    var user: AVUser!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avaImg.layer.cornerRadius = avaImg.frame.width / 2
        avaImg.clipsToBounds = true
        // 根据不同的设备型号，动态的设置组件的大小
        let width = UIScreen.main.bounds.width
        avaImg.frame = CGRect(x: 10, y: 10, width: width / 5.3, height: width / 5.3)
        usernameLbl.frame = CGRect(x: avaImg.frame.width + 20, y: 30, width: width / 3.2, height: 30)
        followBtn.frame = CGRect(x: width - width / 3.5 - 20, y: 30, width: width / 3.5, height: 30)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func followBtn_clicked(_ sender: UIButton) {
        let title = followBtn.title(for: .normal)
        if title == "关 注" {
            guard user != nil else { return }
            AVUser.current()!.follow(user.objectId!, andCallback: { (success: Bool, error: Error?) in
                if success {
                    self.followBtn.setTitle("√ 已关注", for: .normal)
                    self.followBtn.backgroundColor = .green
                } else {
                    print(error?.localizedDescription)
                }
            })
        } else {
            guard user != nil else { return }
            AVUser.current()!.unfollow(user.objectId!, andCallback: { (success: Bool, error: Error?) in
                if success {
                    self.followBtn.setTitle("关 注", for: .normal)
                    self.followBtn.backgroundColor = .lightGray
                } else {
                    print(error?.localizedDescription)
                }
            })
        }
    }
}
