//
//  EnterViewController.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/27.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit
import SVProgressHUD

enum PasswordType{
    case New // 输入新密码
    case Enter // 登入检查
    case Verify // 确认密码
}

class EnterPasswordViewController: UIViewController {
    
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var sureButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    
    var passwordDidPass: ((String?, Bool) -> Void)?
    
    var type: PasswordType?
    private var passwordVisable = false
    private var password = "" {
        didSet {
            if passwordVisable {
                passwordLabel.text = password
            } else {
                passwordLabel.text = String(repeating: "*", count: password.characters.count)
            }
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        if type == PasswordType.New {
            sureButton.setTitle("保存", for: .normal)
        }
        self.dismissButton.isHidden = type == PasswordType.Verify
        if type == PasswordType.Enter || type == PasswordType.Verify {
            sureButton.setTitle("确认", for: .normal)
            // Touch ID是否开启
            if UserDefaults.standard.bool(forKey: kEnableTouchID) {
                autherTouchID(reply: { (success, error) -> Void in
                    if success {
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.passwordDidPass?(nil, true)
                            self.dismiss(animated: true, completion: nil)
                        })
                    }
                })
            }
        }
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        passwordDidPass?(password, false)
        dismiss(animated: true, completion: nil)
    }
    
    // 切换密码显示
    @IBAction func enablePasswordVisable(_ sender: UIButton) {
        passwordVisable = !passwordVisable
        let password = self.password
        self.password = password
    }
    
    // 删除
    @IBAction func deleteOneCharacter(_ sender: UIButton) {
        guard password.characters.count > 0 else {
            return
        }
        password.remove(at: password.index(password.endIndex, offsetBy: -1))
    }
    
    // 输入
    @IBAction func enterOneCharacter(_ sender: UIButton) {
        if let character = sender.currentTitle?.characters.first {
            password.append(character)
        }
    }
    
    // 确认
    @IBAction func sure(_ sender: UIButton) {
        if type == PasswordType.New {
            passwordDidPass?(password, true)
            dismiss(animated: true, completion: nil)
        }
        if type == PasswordType.Enter || type == PasswordType.Verify {
            if password.md5 == UserDefaults.standard.object(forKey: kMD5Password) as? String {
                passwordDidPass?(password, true)
                dismiss(animated: true, completion: nil)
            } else {
                SVProgressHUD.showError(withStatus: "密码不正确,请重新输入!")
            }
            
        }
    }
    
}
