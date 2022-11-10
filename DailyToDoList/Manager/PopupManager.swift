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
}
