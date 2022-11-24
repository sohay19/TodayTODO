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
//        guard let navigation = vc.navigationController as? CustomNavigationController else {
//            return
//        }
//        navigation.present(alertPopup, animated: true)
        vc.present(alertPopup, animated: true)
    }
    
    func openOkAlert(_ vc:UIViewController, title:String, msg:String, complete:@escaping (UIAlertAction)->Void) {
        let alertPopup = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertPopup.addAction(UIAlertAction(title: "OK", style: .default, handler: complete))
//        guard let navigation = vc.navigationController as? CustomNavigationController else {
//            return
//        }
//        navigation.present(alertPopup, animated: true)
        vc.present(alertPopup, animated: true)
    }
    
    func openYesOrNo(_ vc:UIViewController, title:String, msg:String, completeYes:@escaping (UIAlertAction)->Void, completeNo:@escaping (UIAlertAction)->Void) {
        let alertPopup = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertPopup.addAction(UIAlertAction(title: "Yes", style: .default, handler: completeYes))
        alertPopup.addAction(UIAlertAction(title: "No", style: .cancel, handler: completeNo))
//        guard let navigation = vc.navigationController as? CustomNavigationController else {
//            return
//        }
//        navigation.present(alertPopup, animated: true)
        vc.present(alertPopup, animated: true)
    }
    
    func openYesOrNo(_ vc:UIViewController, title:String, msg:String, completeYes:@escaping (UIAlertAction)->Void) {
        let alertPopup = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertPopup.addAction(UIAlertAction(title: "Yes", style: .default, handler: completeYes))
        alertPopup.addAction(UIAlertAction(title: "No", style: .cancel))
//        guard let navigation = vc.navigationController as? CustomNavigationController else {
//            return
//        }
//        navigation.present(alertPopup, animated: true)
        vc.present(alertPopup, animated: true)
    }
    
    func openActionSheet(_ vc:UIViewController, title:String, msg:String) {
        let alertSheet = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertSheet.addAction(UIAlertAction(title: "Yes", style: .default))
        alertSheet.addAction(UIAlertAction(title: "Add", style: .default))
        alertSheet.addAction(UIAlertAction(title: "No", style: .cancel))
//        guard let navigation = vc.navigationController as? CustomNavigationController else {
//            return
//        }
//        navigation.present(alertSheet, animated: true)
        vc.present(alertSheet, animated: true)
    }
}
