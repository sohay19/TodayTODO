//
//  ClassExtension.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/24.
//

import Foundation
import UIKit


//MARK: - UIApplicaton
extension UIApplication {
    func topViewController() -> UIViewController? {
        var topViewController: UIViewController? = nil
        if #available(iOS 13, *) {
            for scene in connectedScenes {
                if let windowScene = scene as? UIWindowScene {
                    for window in windowScene.windows {
                        if window.isKeyWindow {
                            topViewController = window.rootViewController
                        }
                    }
                }
            }
        } else {
            topViewController = keyWindow?.rootViewController
        }
        while true {
            if let presented = topViewController?.presentedViewController {
                topViewController = presented
            } else if let navController = topViewController as? UINavigationController {
                topViewController = navController.topViewController
            } else if let tabBarController = topViewController as? UITabBarController {
                topViewController = tabBarController.selectedViewController
            } else {
                // Handle any other third party container in `else if` if required
                break
            }
        }
        return topViewController
    }
}

//MARK: - Text
extension UITextView {
    // 폰트 설정 및 행간 조절 스타일 설정
    func setLineSpacing(_ text:String, font:UIFont, color:UIColor, align:NSTextAlignment) {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        style.alignment = align
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, attributedString.length))
        self.attributedText = attributedString
    }
}

//MARK: - Notification
extension Notification.Name {
    static let FCMToken = Notification.Name("FCMToken")
    static let IAPServicePurchaseNotification = Notification.Name("IAPServicePurchaseNotification")
}
