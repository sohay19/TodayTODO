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
        let alertPopup = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertPopup.addAction(UIAlertAction(title: "OK", style: .default))
        vc.present(alertPopup, animated: true)
    }
    
    func openOkAlert(_ vc:UIViewController, title:String, msg:String, complete:@escaping (UIAlertAction)->Void) {
        let alertPopup = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertPopup.addAction(UIAlertAction(title: "OK", style: .default, handler: complete))
        vc.present(alertPopup, animated: true)
    }
    
    func openYesOrNo(_ vc:UIViewController, title:String, msg:String, completeYes:@escaping (UIAlertAction)->Void, completeNo:@escaping (UIAlertAction)->Void) {
        let alertPopup = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertPopup.addAction(UIAlertAction(title: "Yes", style: .default, handler: completeYes))
        alertPopup.addAction(UIAlertAction(title: "No", style: .destructive, handler: completeNo))
        vc.present(alertPopup, animated: true)
    }
    
    func openYesOrNo(_ vc:UIViewController, title:String, msg:String, completeYes:@escaping (UIAlertAction)->Void) {
        let alertPopup = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertPopup.addAction(UIAlertAction(title: "Yes", style: .default, handler: completeYes))
        alertPopup.addAction(UIAlertAction(title: "No", style: .destructive))
        vc.present(alertPopup, animated: true)
    }
    
    func openAlertSheet(_ vc:UIViewController, title:String, msg:String, btnMsg:[String], complete:[(UIAlertAction)->Void]) {
        let alertSheet = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        for (i, btn) in btnMsg.enumerated() {
            alertSheet.addAction(
                UIAlertAction(
                title: btn,
                style: i == complete.count-1 ? .destructive : .default,
                handler: complete[i]
                ))
        }
        vc.present(alertSheet, animated: true)
    }
}
