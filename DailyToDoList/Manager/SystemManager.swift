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
    
    private var backgroundView:UIView?
    private var indicator:UIActivityIndicatorView?
}

//MARK: - Loading
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
        backgroundView.alpha = 0.15
        
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

//MARK: - ETC
extension SystemManager {
    @available(iOSApplicationExtension, unavailable)
    func openSettingMenu() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
}

//MARK: - push
extension SystemManager {
    func requestPushPermission() {
        pushManager.requestPermission()
    }
    //
    func addNotification(_ data:EachTask) -> [String] {
        pushManager.addNotification(data)
    }
    //
    func deleteAllPush() {
        pushManager.deleteAllPush()
    }
    
    func checkExpiredPush() {
        pushManager.checkExpiredPush()
    }
    //
    func updatePush(_ idList:[String], _ task:EachTask) -> [String] {
        return pushManager.updatePush(idList, task)
    }
    //
    func deletePush(_ idList:[String]) {
        pushManager.deletePush(idList)
    }
}
