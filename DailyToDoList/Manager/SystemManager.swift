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
    private init() {
        let board = UIStoryboard(name: sideMenuBoard, bundle: nil)
        guard let sideVC = board.instantiateViewController(withIdentifier: sideMenuBoard) as? SideMenuViewController else {
            return
        }
        sideMenu = CustomSideMenuNavigation(rootViewController: sideVC)
    }
    //
    private var navigation:CustomNavigationController?
    private var sideMenu:CustomSideMenuNavigation?
    private var backgroundView:UIView?
    private var indicator:UIActivityIndicatorView?
    //
    private var isLoading = false
}

//MARK: - Loading
extension SystemManager {
    func openLoading() {
        //
        if isLoading {
            return
        }
        isLoading = true
        //
        backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        //
        guard let backgroundView = backgroundView, let indicator = indicator else {
            return
        }
        guard let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        guard let firstWindow = firstScene.windows.first else {
            return
        }
        guard let rootVC = firstWindow.rootViewController else {
            return
        }
        //
        let topVC = getTopViewController(rootVC);
        
        topVC.view.addSubview(backgroundView)
        topVC.view.addSubview(indicator)
        
        backgroundView.frame = CGRect(x: 0, y: 0, width: topVC.view.frame.maxX, height: topVC.view.frame.maxY)
        backgroundView.backgroundColor = .white
        backgroundView.alpha = 0
        
        indicator.style = .large
        indicator.center = topVC.view.center
        indicator.startAnimating()
    }
    private func getTopViewController(_ controller:UIViewController) -> UIViewController {
        if let navigationController = controller as? UINavigationController {
            return getTopViewController(navigationController.visibleViewController!)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return getTopViewController(selected)
            }
        }
        if let presented = controller.presentedViewController {
            return getTopViewController(presented)
        }
        return controller
    }
    //
    func closeLoading() {
        if !isLoading {
            return
        }
        guard let backgroundView = backgroundView, let indicator = indicator else {
            return
        }
        backgroundView.removeFromSuperview()
        indicator.removeFromSuperview()
        //
        isLoading = false
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
        navigation = vc.navigationController as? CustomNavigationController
        guard let sideMenu = sideMenu, let navigation = navigation else {
            return
        }
        navigation.present(sideMenu, animated: true) {
            self.closeLoading()
        }
    }
    //Main Page
    func moveMain() {
        guard let navigation = navigation else {
            return
        }
        navigation.popToRootViewController()
    }
    //Push Page
    func movePush() {
        let board = UIStoryboard(name: pushListBoard, bundle: nil)
        guard let nextVC = board.instantiateViewController(withIdentifier: pushListBoard) as? PushListViewController else { return
        }
        guard let navigation = navigation else {
            return
        }
        navigation.pushViewController(nextVC)
    }
    //BackUp Page
    func moveBackup() {
        let board = UIStoryboard(name: settingBoard, bundle: nil)
        guard let nextVC = board.instantiateViewController(withIdentifier: settingBoard) as? SettingViewController else { return }
        guard let navigation = navigation else {
            return
        }
        navigation.pushViewController(nextVC)
    }
}

//MARK: - ETC
extension SystemManager {
    //
    func getUUID() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
}
