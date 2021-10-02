//
//  SignUpVC.swift
//  Instagram
//
//  Created by 吴洲洋 on 2021/9/17.
//

import UIKit

class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var avaImg: UIImageView!
    
    @IBOutlet var usernameTxt: UITextField!
    
    @IBOutlet var passwordTxt: UITextField!
    
    @IBOutlet var repeatPasswordTxt: UITextField!
    
    @IBOutlet var emailTxt: UITextField!
    
    @IBOutlet var fullnameTxt: UITextField!
    
    @IBOutlet var bioTxt: UITextField!
    
    @IBOutlet var webTxt: UITextField!
    
    @IBOutlet var scrollView: UIScrollView!
    
    private var scrollViewHeight: CGFloat = 0
    
    private var keyboard = CGRect()
    
    @IBOutlet var signUpBtn: UIButton!
    
    @IBOutlet var cancelBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.scrollView.contentSize.height = self.view.frame.height
        self.scrollViewHeight = self.view.frame.height
        NotificationCenter.default.addObserver(self, selector: #selector(self.showKeyboard),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideKeyboard),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        // UIScreen类定义了基于硬件显示的相
        // Do any additional setup after loading the view.
        // 设置加载photo
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(self.loadImg))
        imgTap.numberOfTapsRequired = 1
        self.avaImg.isUserInteractionEnabled = true
        self.avaImg.addGestureRecognizer(imgTap)
    }
    
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func signUpBtn_clicked(_ sender: UIButton) {
        self.view.endEditing(true)
        
        // 校验用户数据
        if self.usernameTxt.text!.isEmpty || self.passwordTxt.text!.isEmpty || self.repeatPasswordTxt.text!.isEmpty || self.emailTxt.text!.isEmpty || self.fullnameTxt.text!.isEmpty || self.bioTxt.text!.isEmpty || self.webTxt.text!.isEmpty {
            let alert = UIAlertController(title: "请注意", message: "请填写好所有的字段", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if self.passwordTxt.text != self.repeatPasswordTxt.text {
            let alert = UIAlertController(title: "请注意", message: "两次输入的密码不一致", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        let user = AVUser()
        
        print("用户登录信息如下\n username:\(self.usernameTxt.text!.lowercased())\n" +
            "email:\(self.emailTxt.text!.lowercased())\n" +
            "password:\(self.passwordTxt.text!)\n" +
            "fullname:\(String(describing: self.fullnameTxt.text!))\n" +
            "bio:\(self.bioTxt.text!)\n" +
            "web:\(self.webTxt.text!)")
        
        user.username = self.usernameTxt.text!.lowercased()
        user.email = self.emailTxt.text
        user.password = self.passwordTxt.text!
        user["fullname"] = self.fullnameTxt.text!
        user["bio"] = self.bioTxt.text!
        user["web"] = self.webTxt.text!
        
        let avaData = self.avaImg.image!.jpegData(compressionQuality: 0.5)
        let avaFile = AVFile(name: "ava.jpg", data: avaData!)
        user["ava"] = avaFile
        
        user.signUpInBackground { (success: Bool, error: Error?) in
            print("进行用户注册")
            if success {
                print("用户注册成功！！！")
                AVUser.logInWithUsername(inBackground: user.username!, password: user.password!) { (user: AVUser?, error: Error?) in
                    if let user = user {
                        UserDefaults.standard.set(user.username, forKey: "username")
                        UserDefaults.standard.synchronize()
                        // 从AppDelegate类中调用login方法
                        let sceneDelegate: SceneDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
                        sceneDelegate.login()
                    } else {
                        print("保存用户登录信息失败 \(String(describing: error?.localizedDescription))")
                    }
                }
                
            } else {
                print("用户注册失败，失败信息：\(String(describing: error?.localizedDescription))")
            }
        }
        
        print("注册按钮被按下")
    }
    
    @IBAction func cancelBtn_clicked(_ sender: UIButton) {
        print("取消按钮被按下")
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func showKeyboard(notification: Notification) {
        let rect = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        self.keyboard = rect.cgRectValue
        UIView.animate(withDuration: 0.4) {
            self.scrollView.frame.size.height = self.scrollViewHeight - self.keyboard.size.height
        }
    }
    
    @objc func hideKeyboard(notification: Notification) {
        UIView.animate(withDuration: 0.4) {
            self.scrollView.frame.size.height = self.view.frame.height
        }
    }
    
    @objc func hideKeyboardTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc func loadImg(recognizer: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        print("启动照片选择器")
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
        self.dismiss(animated: true) {
            print("UIImagePickerController: dismissed")
        }
    }
}
