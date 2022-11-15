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
    //
    private var navigation:CustomNavigationController?
    private var menuView:Menu?
    private var loadingView:Loading?
    //
    private var isLoading = false
    private var currentPage:PageType = .Main
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
        navigation = topVC.navigationController as? CustomNavigationController
        // 로딩화면 추가
        loadingView = Bundle.main.loadNibNamed(LoadingBoard, owner: topVC, options: nil)?.first as? Loading
        guard let loadingView = loadingView else {
            return
        }
        loadingView.frame = topVC.view.frame
        topVC.view.addSubview(loadingView)
        loadingView.initUI()
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
        guard let loadingView = loadingView else {
            return
        }
        loadingView.removeFromSuperview()
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
    func openMenu(_ vc:UIViewController) {
        // 메뉴로드
        menuView = Bundle.main.loadNibNamed(menuBoard, owner: vc, options: nil)?.first as? Menu
        guard let menuView = menuView else {
            return
        }
        menuView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(menuView)
        menuView.initUI(currentPage == .Backup ? .systemBackground : .label)
        menuView.leadingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        menuView.trailingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        menuView.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        menuView.heightAnchor.constraint(equalToConstant: 69).isActive = true
    }
    //Main Page
    func moveMain() {
        guard let navigation = navigation else {
            return
        }
        currentPage = .Main
        navigation.popToRootViewController()
    }
    //Push Page
    func movePush() {
        let board = UIStoryboard(name: pushListBoard, bundle: nil)
        guard let nextVC = board.instantiateViewController(withIdentifier: pushListBoard) as? PushListViewController else { return }
        guard let navigation = navigation else {
            return
        }
        currentPage = .Push
        navigation.pushViewController(nextVC)
    }
    //BackUp Page
    func moveBackup() {
        let board = UIStoryboard(name: settingBoard, bundle: nil)
        guard let nextVC = board.instantiateViewController(withIdentifier: settingBoard) as? SettingViewController else { return }
        guard let navigation = navigation else {
            return
        }
        currentPage = .Backup
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
