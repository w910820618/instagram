//
//  ResetPasswordVC.swift
//  Instagram
//
//  Created by 吴洲洋 on 2021/9/19.
//

import UIKit

class ResetPasswordVC: UIViewController {
    @IBOutlet var emailTxt: UITextField!

    @IBOutlet var resetBtn: UIButton!

    @IBOutlet var cancelBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

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

    @IBAction func resetBtn_clicked(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.emailTxt.text!.isEmpty {
            let alert = UIAlertController(title: "请注意", message: "电子邮件不能为空", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        AVUser.requestPasswordResetForEmail(inBackground: self.emailTxt.text!) { (success: Bool, error: Error?) in
            if success {
                let alert = UIAlertController(title: "请注意", message: "重置密码连接已经发送到您的电子邮件!", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            } else {
                print(error?.localizedDescription as Any)
            }
        }
    }

    @IBAction func cancelBtn_clicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
