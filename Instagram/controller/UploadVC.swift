//
//  UploadVC.swift
//  Instagram
//
//  Created by 吴洲洋 on 2021/9/21.
//

import UIKit

class UploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var picImg: UIImageView!

    @IBOutlet var titleTxt: UITextView!

    @IBOutlet var removeBtn: UIButton!
    @IBOutlet var publishBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        publishBtn.isEnabled = false
        publishBtn.backgroundColor = .lightGray

        // Do any additional setup after loading the view.
        let picTap = UITapGestureRecognizer(target: self, action: #selector(selectImg))
        picTap.numberOfTapsRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(picTap)

        removeBtn.isHidden = true

        alignment()
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */

    func alignment() {
        let width = view.frame.width
        picImg.frame = CGRect(x: 15, y: navigationController!.navigationBar.frame.height + 35, width: width / 4.5, height: width / 4.5)
        titleTxt.frame = CGRect(x: picImg.frame.width + 25, y: picImg.frame.origin.y, width: width - titleTxt.frame.origin.x - 10, height: picImg.frame.height)
        publishBtn.frame = CGRect(x: 0, y: tabBarController!.tabBar.frame.origin.y - width / 8, width: width, height: width / 8)
        removeBtn.frame = CGRect(x: picImg.frame.origin.x, y: picImg.frame.origin.y + picImg.frame.height, width: picImg.frame.width, height: 30)
    }

    @objc func selectImg() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }

    // 选择图库中的图片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
    {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("error: did not picked a photo")
        }

        picker.dismiss(animated: true) { [unowned self] in
            self.picImg.image = selectedImage
        }

        removeBtn.isHidden = false
        // 允许 publish btn
        publishBtn.isEnabled = true
        publishBtn.backgroundColor = UIColor(red: 52.0 / 255.0, green: 169.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)

        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(zoomImg))
        zoomTap.numberOfTapsRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(zoomTap)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true) {
            print("UIImagePickerController: dismissed")
        }
    }

    // 放大或缩小照片
    @objc func zoomImg() {
        // 放大后的Image View的位置
        let zoomed = CGRect(x: 0, y: view.center.y - view.center.x, width: view.frame.width, height: view.frame.width)
        // Image View还原到初始位置
        let unzoomed = CGRect(x: 15, y: navigationController!.navigationBar.frame.height + 35, width: view.frame.width / 4.5, height: view.frame.width / 4.5)

        // 如果Image View是初始大小
        if picImg.frame == unzoomed {
            UIView.animate(withDuration: 0.3, animations: {
                self.picImg.frame = zoomed
                self.view.backgroundColor = .black
                self.titleTxt.alpha = 0
                self.publishBtn.alpha = 0
            })
        } else {
            // 如果是放大后的状态
            UIView.animate(withDuration: 0.3, animations: {
                self.picImg.frame = unzoomed
                self.view.backgroundColor = .white
                self.titleTxt.alpha = 1
                self.publishBtn.alpha = 1
            })
        }
    }

    @IBAction func removeBtn_clicked(_ sender: Any) {
        viewDidLoad()
    }

    @IBAction func publishBtn_clicked(_ sender: Any) {
        view.endEditing(true)
        let object = AVObject(className: "Posts")
        object["username"] = AVUser.current()?.username
        object["ava"] = AVUser.current()?.value(forKey: "ava") as! AVFile
        object["puuid"] = "\(String(describing: AVUser.current()?.username!)) \(NSUUID().uuidString)"

        // titleTxt是否为空
        if titleTxt.text.isEmpty {
            object["title"] = ""
        } else {
            object["title"] = titleTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }

        let imageData = picImg.image!.jpegData(compressionQuality: 0.5)
        let imageFile = AVFile(name: "post.jpg", data: imageData!)
        object["pic"] = imageFile

        // 将最终数据存储到LeanCloud云端
        object.saveInBackground { (_: Bool, error: Error?) in
            if error == nil {
                // 发送 uploaded 通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploaded"), object: nil)
                // 将TabBar控制器中索引值为0的子控制器，显示在手机屏幕上。
                self.tabBarController!.selectedIndex = 0

                self.viewDidLoad()
            }
        }
    }
}
