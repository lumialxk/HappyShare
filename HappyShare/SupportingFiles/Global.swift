//
//  Global.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/25.
//  Copyright © 2016年 李现科. All rights reserved.
//

import Foundation
import LocalAuthentication

let tiffanyBlue = UIColor(red: 129.0/255.0, green: 216.0/255.0, blue: 207.0/255.0, alpha: 1.0)
let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height
let kScreenScale = UIScreen.main.scale

let placeholderImageName = "ic_placeholder"
let kNoteDidModifyNotification = "kNoteDidModifyNotification"
let kEnablePassword = "EnablePassword"
let kFirstLaunch = "FirstLaunch"
let kEnableTouchID = "EnableTouchID"
let kMD5Password = "kMD5Password"
let adMobId = "ca-app-pub-9024023807958943/1299238118"
let iCloudContainerIdentifier = "iCloud.com.tjrc.test"

// 32位MD5加密
extension String {
    var md5: String {
        get {
            var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            if var data = self.data(using: String.Encoding.utf8) {
                CC_MD5(&data, CC_LONG(data.count), &digest)
            }
            var md5String = ""
            for i in 0..<Int(CC_MD5_DIGEST_LENGTH) {
                md5String += String(format: "%02x", arguments: [digest[i]])
            }
            print("\(md5String)")
            return md5String
        }
    }
}

// Touch ID授权
func autherTouchID(reply: @escaping (_ success: Bool, _ error: Error?) -> Void) {
    let context = LAContext()
    var error: NSError?
    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "请认证Touch ID", reply: { (success, error) -> Void in
            reply(success, error)
        })
    }
}

// 显示授权警告
func showAuthorizeAlertView(notice: String ,sender: UIViewController) {
    let alertController = UIAlertController(title: notice,
        message: nil,
        preferredStyle: .alert)
    
    let settingsAction = UIAlertAction(title: "设置", style: .default) { (alertAction) in
        if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
            DispatchQueue.main.async(execute: {
                UIApplication.shared.openURL(appSettings)
            })
        }
    }
    alertController.addAction(settingsAction)
    
    let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
    alertController.addAction(cancelAction)
    alertController.view.tintColor = tiffanyBlue
    sender.present(alertController, animated: true, completion: nil)
}

extension String {
    subscript (range: Range<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
            let endIndex   = self.index(self.startIndex, offsetBy: range.upperBound)
            return self[startIndex..<endIndex]
        }
    }
}

extension UIView {
    var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }
    
    var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
    
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }
    
    var centerX: CGFloat {
        get {
            return center.x
        }
        set {
            center.x = newValue
        }
    }
    
    var centerY: CGFloat {
        get {
            return center.y
        }
        set {
            center.y = newValue
        }
    }
    
    var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            frame.origin = newValue
        }
    }
    
    var size: CGSize {
        get {
            return frame.size
        }
        set {
            frame.size = newValue
        }
    }
}

extension UIColor {
    convenience init(rgb: Int,alpha: CGFloat = 1.0) {
        let r = CGFloat(rgb / 0x10000) / 255.0
        let g = CGFloat(rgb % 0x10000 / 0x100) / 255.0
        let b = CGFloat(rgb % 0x100) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

// 秒转换
struct Period {
    let seconds: Int
    var minutes: Int {
        get {
            return seconds / 60
        }
    }
    var hours: Int {
        get {
            return seconds / 3600
        }
    }
    var secondComponent: Int {
        get {
            return seconds % 60
        }
    }
    var minuteComponent: Int {
        get {
            return seconds % 3600 / 60
        }
    }
    var hourComponent: Int {
        get {
            return seconds / 3600
        }
    }
    var fullFormat: String {
        get {
            return String(format: "%02d:%02d:%02d", arguments: [hourComponent,minuteComponent,secondComponent])
        }
    }
    var natuaralFormat: String {
        get {
            var format = String(format: "%02d", arguments: [secondComponent])
            if hours > 0 {
                format = String(format: "%02d:%02d:", arguments: [hourComponent,minuteComponent]) + format
            } else if minutes > 0 {
                format = String(format: "%02d:", arguments: [minuteComponent]) + format
            }
            return format
        }
    }
}

enum MaskOrientation {
    case Left
    case Right
    case Top
    case Bottom
    case Around
}

func addMaskViewFromView(fromView: UIView,toView: UIView,orientation: MaskOrientation) {
    let fromFrame = fromView.convert(fromView.frame, to: toView)
    let maskView = UIView()
    switch orientation {
    case .Left:
        maskView.x = 0
        maskView.y = 0
        maskView.width = toView.width - fromFrame.origin.x
        maskView.height = toView.height
    case .Right:
        maskView.x = fromFrame.origin.x + fromFrame.size.width
        maskView.y = 0
        maskView.width = toView.width - fromFrame.origin.x - fromFrame.size.width
        maskView.height = toView.height
    case .Top:
        maskView.x = 0
        maskView.y = 0
        maskView.width = toView.width
        maskView.height = toView.height - fromFrame.origin.y
    case .Bottom:
        maskView.x = 0
        maskView.y = fromFrame.origin.y + fromFrame.size.height
        maskView.width = toView.width
        maskView.height = toView.height - fromFrame.origin.y - fromFrame.size.height
    case .Around:
        maskView.size = toView.size
    }
    maskView.backgroundColor = UIColor.black
    maskView.alpha = 0.45
    toView.addSubview(maskView)
    toView.bringSubview(toFront: fromView)
}






