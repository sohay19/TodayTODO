//
//  PopupManager.swift
//  dailytimetable
//
//  Created by 소하 on 2022/09/07.
//

import Foundation
import UIKit

class PopupManager {
    static let shared = PopupManager()
    private init() { }
}

//MARK: - Default Popup
extension PopupManager {
    func openOkAlert(_ vc:UIViewController, title:String, msg:String) {
        let errorPopup = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        errorPopup.addAction(UIAlertAction(title: "OK", style: .default))
        
        vc.present(errorPopup, animated: true)
    }
    
    func openOkAlert(_ vc:UIViewController, title:String, msg:String, complete:@escaping (UIAlertAction)->Void) {
        let errorPopup = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        errorPopup.addAction(UIAlertAction(title: "OK", style: .default, handler: complete))
        
        vc.present(errorPopup, animated: true)
    }
    
    func openYesOrNo(_ vc:UIViewController, title:String, msg:String, completeYes:@escaping (UIAlertAction)->Void, completeNo:@escaping (UIAlertAction)->Void) {
        let alertPopup = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertPopup.addAction(UIAlertAction(title: "Yes", style: .default, handler: completeYes))
        alertPopup.addAction(UIAlertAction(title: "No", style: .cancel, handler: completeNo))
        
        vc.present(alertPopup, animated: true)
    }
    
    func openYesOrNo(_ vc:UIViewController, title:String, msg:String, completeYes:@escaping (UIAlertAction)->Void) {
        let alertPopup = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertPopup.addAction(UIAlertAction(title: "Yes", style: .default, handler: completeYes))
        alertPopup.addAction(UIAlertAction(title: "No", style: .cancel))
        
        vc.present(alertPopup, animated: true)
    }
    
    func openNickPopup(_ vc:UIViewController, title:String, msg:String, labelNick: UILabel, complete:@escaping (UIAlertAction)->Void) {
        let alertPopup = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertPopup.addTextField { textfield in
            textfield.keyboardType = .asciiCapable
            textfield.keyboardAppearance = .dark
            textfield.placeholder = "알파벳 대문자/소문자, 숫자만 사용가능합니다.\n최소 4~8자까지 가능합니다"
        }
        alertPopup.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            guard let textField = alertPopup.textFields else {
                return
            }
            let input = textField[0].text!
            if input.isEmpty {
                self.openNickPopup(vc, title: title, msg: "알파벳 대문자/소문자, 숫자만 사용가능합니다.\n최소 4자 이상 입력해주세요", labelNick: labelNick, complete: complete)
            } else if input.count > 8 || input.count < 4 {
                self.openNickPopup(vc, title: title, msg: "알파벳 대문자/소문자, 숫자만 사용가능합니다.\n최소 4자 이상, 8자 이하까지 가능합니다", labelNick: labelNick, complete: complete)
            } else {
                let pattern = "^[0-9a-zA-Z]*$"
                guard let _ = input.range(of: pattern, options: .regularExpression) else {
                    self.openNickPopup(vc, title: title, msg: "알파벳 대문자/소문자, 숫자만 사용가능합니다.", labelNick: labelNick, complete: complete)
                    return
                }
                DataManager.shared.checkNickName(input) { isExist in
                    if isExist {
                        self.openNickPopup(vc, title: title, msg: "알파벳 대문자/소문자, 숫자만 사용가능합니다.\n중복된 닉네임 입니다", labelNick: labelNick, complete: complete)
                    } else {
                        labelNick.text = input
                        complete(action)
                    }
                }
            }
        }))
        alertPopup.addAction(UIAlertAction(title: "No", style: .cancel))
        
        vc.present(alertPopup, animated: true)
    }
}
