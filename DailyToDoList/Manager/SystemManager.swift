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
    private var menuView:Menu?
    private var loadingView:Loading?
    //
    private var isLoading = false
    private var pageList:[PageType] = [.Main]
}

//MARK: - Loading
extension SystemManager {
    func openLoading() {
        //
        if isLoading {
            return
        }
        isLoading = true
        guard let topVC = findTopVC() else {
            return
        }
        // 로딩화면 추가
        loadingView = Bundle.main.loadNibNamed(LoadingBoard, owner: topVC, options: nil)?.first as? Loading
        guard let loadingView = loadingView else {
            return
        }
        loadingView.frame = topVC.view.frame
        topVC.view.addSubview(loadingView)
        loadingView.initUI()
    }
    private func findTopVC() -> UIViewController? {
        guard let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        guard let firstWindow = firstScene.windows.first else {
            return nil
        }
        guard let rootVC = firstWindow.rootViewController else {
            return nil
        }
        return getTopViewController(rootVC);
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
    func openTaskInfo(_ mode:TaskMode, date:Date?, task:EachTask?, load:(() -> Void)?, modify:((EachTask)->Void)?) {
        let board = UIStoryboard(name: taskInfoBoard, bundle: nil)
        guard let taskInfoVC = board.instantiateViewController(withIdentifier: taskInfoBoard) as? TaskInfoViewController else { return }
        //
        taskInfoVC.currentMode = mode
        taskInfoVC.currntDate = date == nil ? Date() : date!
        taskInfoVC.refreshTask = load
        taskInfoVC.modifyTask = modify
        //
        taskInfoVC.taskData = task
        taskInfoVC.modalTransitionStyle = .coverVertical
        taskInfoVC.modalPresentationStyle = .overFullScreen
        guard let navigation = findTopVC()?.navigationController as? CustomNavigationController else {
            return
        }
        navigation.pushViewController(taskInfoVC)
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
        menuView.initUI(pageList.last! == .Backup ? .systemBackground : .label)
        menuView.leadingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        menuView.trailingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        menuView.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        menuView.heightAnchor.constraint(equalToConstant: 69).isActive = true
    }
    //Main Page
    func moveMain() {
        if  pageList.last! == .Main {
            return
        }
        guard let navigation = findTopVC()?.navigationController as? CustomNavigationController else {
            return
        }
        pageList = [.Main]
        navigation.popToRootViewController()
    }
    //
    func moveCategory() {
        if  pageList.last! == .Category {
            return
        }
    }
    //Push Page
    func movePush() {
        if  pageList.last! == .Push {
            return
        }
        let board = UIStoryboard(name: pushListBoard, bundle: nil)
        guard let nextVC = board.instantiateViewController(withIdentifier: pushListBoard) as? PushListViewController else { return }
        guard let navigation = findTopVC()?.navigationController as? CustomNavigationController else {
            return
        }
        if pageList.count > 1 && pageList[pageList.endIndex-2] == .Push {
            pageList.removeLast()
            navigation.popViewController()
        } else {
            pageList.append(.Push)
            navigation.pushViewController(nextVC)
        }
    }
    //BackUp Page
    func moveBackup() {
        if  pageList.last! == .Backup {
            return
        }
        let board = UIStoryboard(name: settingBoard, bundle: nil)
        guard let nextVC = board.instantiateViewController(withIdentifier: settingBoard) as? SettingViewController else { return }
        guard let navigation = findTopVC()?.navigationController as? CustomNavigationController else {
            return
        }
        if pageList.count > 1 && pageList[pageList.endIndex-2] == .Backup {
            pageList.removeLast()
            navigation.popViewController()
        } else {
            pageList.append(.Backup)
            navigation.pushViewController(nextVC)
        }
    }
}

//MARK: - ETC
extension SystemManager {
    //
    func getUUID() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
}
