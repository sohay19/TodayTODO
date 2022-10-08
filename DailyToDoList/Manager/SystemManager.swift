//
//  SystemManager.swift
//  dailytimetable
//
//  Created by 소하 on 2022/09/08.
//

import UIKit
import Foundation

class SystemManager {
    static let shared = SystemManager()
    private init() { }
    
    private let pushManager = PushManager()
    //
    private var backgroundView:UIView?
    private var indicator:UIActivityIndicatorView?
}

extension SystemManager {
    func openLoading(_ topVC:UIViewController) {
        backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        guard let backgroundView = backgroundView, let indicator = indicator else {
            return
        }
        
        topVC.view.addSubview(backgroundView)
        topVC.view.addSubview(indicator)
        
        backgroundView.frame = CGRect(x: 0, y: 0, width: topVC.view.frame.maxX, height: topVC.view.frame.maxY)
        backgroundView.backgroundColor = .white
        backgroundView.alpha = 0.25
        
        indicator.style = .large
        indicator.center = topVC.view.center
        indicator.startAnimating()
    }
    //
    func closeLoading() {
        guard let backgroundView = backgroundView, let indicator = indicator else {
            return
        }
        backgroundView.removeFromSuperview()
        indicator.removeFromSuperview()
    }
}


extension SystemManager {
    func openSettingMenu() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    
    func requestPushPermission() {
        pushManager.requestPermission()
    }
}
