//
//  PictureCell.swift
//  Instagram
//
//  Created by 吴洲洋 on 2021/9/19.
//

import UIKit

class PictureCell: UICollectionViewCell {
    @IBOutlet var picImg: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        let width = UIScreen.main.bounds.width
        picImg.frame = CGRect(x: 0, y: 0, width: width / 3, height: width / 3)
    }
}
