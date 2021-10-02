//
//  SignInVC.swift
//  Instagram
//
//  Created by 吴洲洋 on 2021/9/17.
//

import UIKit

class SignInVC: UIViewController {
    @IBOutlet var label: UILabel!
    
    @IBOutlet var usernameTxt: UITextField!
    
    @IBOutlet var passwordTxt: UITextField!
    
    @IBOutlet var forgotBtn: UIButton!
    
    @IBOutlet var signInBtn: UIButton!
    
    @IBOutlet var signUpBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // UITapGestureRecognizer 设置单击手势识别
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(hideTap)
        
        label.font = UIFont(name: "Pacifico", size: 50)
    }
    
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */

    @IBAction func siginInBtn_clicked(_ sender: UIButton) {
        view.endEditing(true)
    }
    
    @IBAction func siginUpBtn_clicked(_ sender: UIButton) {
        print("登录按钮被单击")
        // 隐藏键盘
        if usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty {
            // 定义了 alert 提示框，并向 alert 中添加action
            let alert = UIAlertController(title: "请注意", message: "请填写好所有的字段", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)

        }
        
        AVUser.logInWithUsername(inBackground: usernameTxt.text!, password: passwordTxt.text!) { (user: AVUser?, error: Error?) in
            if error == nil {
                // 记住用户
                UserDefaults.standard.set(user!.username, forKey: "username")
                UserDefaults.standard.synchronize()
                print("用户登录成功")
                // 调用sceneDelegate类的login方法 切换场景需要在SceneDelegate中执行才可以
                let sceneDelegate: SceneDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
                sceneDelegate.login()
            } else {
                print("登录失败的原因：\(error.debugDescription)")
            }
        }
    }
    
    @IBAction func forgotBtn_clicked(_ sender: UIButton) {}
    
    @objc func hideKeyboard(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}
