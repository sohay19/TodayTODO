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
    private var loadingView:Loading?
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
}

//MARK: - ETC
extension SystemManager {
    //
    func getUUID() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
}
