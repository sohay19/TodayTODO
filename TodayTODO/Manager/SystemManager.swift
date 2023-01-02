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
        //
        setTheme(topVC)
        // 로딩화면 추가
        loadingView = Bundle.main.loadNibNamed(LoadingBoard, owner: topVC, options: nil)?.first as? Loading
        guard let loadingView = loadingView else {
            return
        }
        loadingView.frame = topVC.view.frame
        topVC.view.addSubview(loadingView)
        loadingView.initUI()
    }
    private func findWindow() -> UIWindow? {
        guard let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        guard let firstWindow = firstScene.windows.first else {
            return nil
        }
        return firstWindow
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

//MARK: - Help
extension SystemManager {
    func openHelp(_ vc:UIViewController, _ board:String) {
        var isHelp = false
        switch board {
        case mainBoard:
            isHelp = UserDefaults.shared.bool(forKey: HelpMainKey)
        case categoryBoard:
            isHelp = UserDefaults.shared.bool(forKey: HelpCategoryKey)
        case pushBoard:
            isHelp = UserDefaults.shared.bool(forKey: HelpPushKey)
        default:
            break
        }
        if !isHelp {
            guard let tabVC = vc.tabBarController as? CustomTabBarController else { return }
            let helpView = Bundle.main.loadNibNamed(helpBoard, owner: vc, options: nil)?.first as? Help
            guard let helpView = helpView else {
                return
            }
            helpView.controllTabBar = {
                tabVC.controllTabItem(true)
            }
            helpView.frame = vc.view.frame
            vc.view.addSubview(helpView)
            helpView.setView(board)
            //
            tabVC.controllTabItem(false)
        }
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
    func setTheme(_ vc:UIViewController) {
        let theme = DataManager.shared.getTheme()
        switch theme {
        case WhiteBackImage:
            vc.overrideUserInterfaceStyle = .light
        case BlackBackImage:
            vc.overrideUserInterfaceStyle = .dark
        case PaperBackImage:
            vc.overrideUserInterfaceStyle = .light
        default:
            break
        }
    }
    // UUID 조회
    func getUUID() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    // 디바이스 OS 버전 조회
    func getOsVersion() -> String {
        return UIDevice.current.systemVersion
    }
    // 디바이스 모델 조회
    func getModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let model = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return model
    }
    // 디바이스 모델명 조회
    func getModelName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let model = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        switch model {
            // Simulator
            case "i386", "x86_64":                          return "Simulator"
            // iPod
            case "iPod1,1":                                 return "iPod Touch"
            case "iPod2,1", "iPod3,1", "iPod4,1":           return "iPod Touch"
            case "iPod5,1", "iPod7,1":                      return "iPod Touch"
            // iPad
            case "iPad1,1":                                 return "iPad"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
            // iPhone
            case "iPhone1,1", "iPhone1,2", "iPhone2,1":     return "iPhone"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPhone12,8":                              return "iPhone SE 2nd Gen"
            case "iPhone13,1":                              return "iPhone 12 Mini"
            case "iPhone13,2":                              return "iPhone 12"
            case "iPhone13,3":                              return "iPhone 12 Pro"
            case "iPhone13,4":                              return "iPhone 12 Pro Max"
            default:                                        return model
        }
    }
}
