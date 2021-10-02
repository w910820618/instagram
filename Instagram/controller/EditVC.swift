//
//  EditVC.swift
//  Instagram
//
//  Created by 吴洲洋 on 2021/9/21.
//

import UIKit

class EditVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var genderPicker: UIPickerView!
    let genders = ["男", "女"]
    var keyboard = CGRect()

    @IBOutlet var scrollView: UIScrollView!

    @IBOutlet var avaImg: UIImageView!

    @IBOutlet var fullnameTxt: UITextField!

    @IBOutlet var usernameTxt: UITextField!

    @IBOutlet var webTxt: UITextField!

    @IBOutlet var bioTxt: UITextView!

    @IBOutlet var emailTxt: UITextField!

    @IBOutlet var telTxt: UITextField!

    @IBOutlet var genderTxt: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(hideTap)

        // 在视图中创建PickerView
        genderPicker = UIPickerView()
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderPicker.backgroundColor = UIColor.groupTableViewBackground
        genderPicker.showsSelectionIndicator = true
        genderTxt.inputView = genderPicker

        // 单击image view
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(loadImg))
        imgTap.numberOfTapsRequired = 1
        avaImg.isUserInteractionEnabled = true
        avaImg.addGestureRecognizer(imgTap)

        alignment()

        information()

        // Do any additional setup after loading the view.
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }

    // 设置获取器的选项Title
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }

    // 从获取器中得到用户选择的Item
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTxt.text = genders[row]
        view.endEditing(true)
    }

    @IBAction func save_clicked(_ sender: Any) {
        let user = AVUser.current()
        user?.username = usernameTxt.text?.lowercased()
        user?.email = emailTxt.text?.lowercased()
        user?["fullname"] = fullnameTxt.text?.lowercased()
        user?["web"] = webTxt.text?.lowercased()
        user?["bio"] = bioTxt.text
        if telTxt.text!.isEmpty {
            user?.mobilePhoneNumber = ""
        } else {
            user?.mobilePhoneNumber = telTxt.text
        }
        // 如果 gender 为空，则发送""给gender字段，否则传入信息
        if genderTxt.text!.isEmpty {
            user?["gender"] = ""
        } else {
            user?["gender"] = genderTxt.text
        }

        user?.saveInBackground { (success: Bool, error: Error?) in
            if success {
                // 隐藏键盘
                self.view.endEditing(true)
                // 退出EditVC控制器
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
            } else {
                print(error?.localizedDescription)
            }
        }
    }

    @IBAction func cancel_clicked(_ sender: Any) {}

    // 动态计算布局
    func alignment() {
        let width = view.frame.width
        let height = view.frame.height
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        avaImg.frame = CGRect(x: width - 68 - 10, y: 15, width: 68, height: 68)
        avaImg.layer.cornerRadius = avaImg.frame.width / 2
        avaImg.clipsToBounds = true
        fullnameTxt.frame = CGRect(x: 10, y: avaImg.frame.origin.y, width: width - avaImg.frame.width - 30, height: 30)
        usernameTxt.frame = CGRect(x: 10, y: fullnameTxt.frame.origin.y + 40, width: width - avaImg.frame.width - 30, height: 30)
        webTxt.frame = CGRect(x: 10, y: usernameTxt.frame.origin.y + 40, width: width - 20, height: 30)
        bioTxt.frame = CGRect(x: 10, y: webTxt.frame.origin.y + 40, width: width - 20, height: 60)
        fullnameTxt.frame = CGRect(x: 10, y: avaImg.frame.origin.y, width: width - avaImg.frame.width - 30, height: 30)
        usernameTxt.frame = CGRect(x: 10, y: fullnameTxt.frame.origin.y + 40, width: width - avaImg.frame.width - 30, height: 30)
        webTxt.frame = CGRect(x: 10, y: usernameTxt.frame.origin.y + 40, width: width - 20, height: 30)
        bioTxt.frame = CGRect(x: 10, y: webTxt.frame.origin.y + 40, width: width - 20, height: 60)
        bioTxt.frame = CGRect(x: 10, y: webTxt.frame.origin.y + 40, width: width - 20, height: 60)
        // 为bioTxt创建1个点的边线，并设置边线的颜色
        bioTxt.layer.borderWidth = 1
        bioTxt.layer.borderColor = UIColor(red: 230 / 255.0, green: 230 / 255.0, blue: 230 / 255.0, alpha: 1).cgColor
        // 设置bioTxt为圆角
        bioTxt.layer.cornerRadius = bioTxt.frame.width / 50
        bioTxt.clipsToBounds = true
    }

    // 隐藏视图中的虚拟键盘
    @objc func hideKeyboardTap(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @objc func showKeyboard(notification: Notification) {
        // 定义keyboard大小
        let rect = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        keyboard = rect.cgRectValue
        // 当虚拟键盘出现以后，将滚动视图的内容高度变为控制器视图高度加上键盘高度的一半。
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentSize.height = self.view.frame.height + self.keyboard.height / 2
        }
    }

    @objc func hideKeyboard(notification: Notification) {
        // 当虚拟键盘消失后，将滚动视图的内容高度值改变为0，这样滚动视图会根据实际内容设置大小。
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentSize.height = 0
        }
    }

    @objc func loadImg(recognizer: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }

    // 选择图中的照片

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
    {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("error: did not picked a photo")
        }

        picker.dismiss(animated: true) { [unowned self] in
            self.avaImg.image = selectedImage
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true) {
            print("UIImagePickerController: dismissed")
        }
    }

    func information() {
        let ava = AVUser.current()?.object(forKey: "ava") as! AVFile
        ava.getDataInBackground { (data: Data?, _: Error?) in
            self.avaImg.image = UIImage(data: data!)
        }
        // 接收个人用户的文本信息
        usernameTxt.text = AVUser.current()?.username
        fullnameTxt.text = AVUser.current()?.object(forKey: "fullname") as? String
        bioTxt.text = AVUser.current()?.object(forKey: "bio") as? String
        webTxt.text = AVUser.current()?.object(forKey: "web") as? String
        emailTxt.text = AVUser.current()?.email
        telTxt.text = AVUser.current()?.mobilePhoneNumber
        genderTxt.text = AVUser.current()?.object(forKey: "gender") as? String
    }

    // 正则检查Web有效性
    func validateWeb(web: String) -> Bool {
        let regex = "www\\.[A-Za-z0-9._%+-]+\\.[A-Za-z]{2,14}"
        let range = web.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }

    // 正则检查手机号码有效性
    func validateMobilePhoneNumber(mobilePhoneNumber: String) -> Bool {
        let regex = "0?(13|14|15|18)[0-9]{9}"
        let range = mobilePhoneNumber.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
}
