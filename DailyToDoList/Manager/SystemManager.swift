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
    
    private var backgroundView:UIView?
    private var indicator:UIActivityIndicatorView?
    
    private var sideMenuNavigation:CustomSideMenuNavigation?
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
        backgroundView.alpha = 0.1
        
        indicator.style = .medium
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

//MARK: - Menu
extension SystemManager {
    @available (iOSApplicationExtension, unavailable)
    func openSettingMenu() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    //
    func openSideMenu(_ vc:UIViewController) {
        let board = UIStoryboard(name: sideMenuBoard, bundle: nil)
        sideMenuNavigation = board.instantiateViewController(withIdentifier: sideMenuBoard) as? CustomSideMenuNavigation
        guard let sideMenuNavigation = sideMenuNavigation else {
            return
        }
        sideMenuNavigation.beforeVC = vc
        vc.present(sideMenuNavigation, animated: true)
    }
    //Main Page
    func moveMain() {
        guard let sideMenuNavigation = sideMenuNavigation else {
            return
        }
        guard let beforeVC = sideMenuNavigation.beforeVC else {
            return
        }
        guard let navigation = beforeVC.navigationController as? CustomNavigationController else {
            return
        }
        //
        navigation.popToRootViewController(complete: {
            sideMenuNavigation.dismiss(animated: true)
        })
    }
    //Push Page
    func movePush() {
        guard let sideMenuNavigation = sideMenuNavigation else {
            return
        }
        guard let beforeVC = sideMenuNavigation.beforeVC else {
            return
        }
        guard let navigation = beforeVC.navigationController as? CustomNavigationController else {
            return
        }
        //
        let board = UIStoryboard(name: pushListBoard, bundle: nil)
        guard let nextVC = board.instantiateViewController(withIdentifier: pushListBoard) as? PushListViewController else { return }
        //
        navigation.popToRootViewController(complete: {
            navigation.pushViewController(nextVC)
            sideMenuNavigation.dismiss(animated: true)
        })
    }
    //BackUp Page
    func moveBackup() {
        guard let sideMenuNavigation = sideMenuNavigation else {
            return
        }
        guard let beforeVC = sideMenuNavigation.beforeVC else {
            return
        }
        guard let navigation = beforeVC.navigationController as? CustomNavigationController else {
            return
        }
        //
        let board = UIStoryboard(name: settingBoard, bundle: nil)
        guard let nextVC = board.instantiateViewController(withIdentifier: settingBoard) as? SettingViewController else { return }
        //
        navigation.pushViewControllerWithLoading(nextVC, complete: {
            sideMenuNavigation.dismiss(animated: true)
        })
    }
}

extension SystemManager {
    //
    func getUUID() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
}
