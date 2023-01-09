//
//  CustomTabBarController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/18.
//

import Foundation
import UIKit

class CustomTabBarController : UITabBarController {
    let iconList:[String] = ["calendar", "list.bullet", "bell", "gearshape"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.delegate = self
        self.tabBar.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.setTheme(self)
        initTabBar()
    }
}

extension CustomTabBarController {
    //초기화
    func initTabBar() {
        guard let mainTab = self.storyboard!.instantiateViewController(withIdentifier: TODOBoard) as? TODOViewController else { return }
        
        let categoryboard = UIStoryboard(name: CategoryBoard, bundle: nil)
        guard let categoryTab = categoryboard.instantiateViewController(withIdentifier: CategoryBoard) as? CategoryViewController else { return }
        
        let pushboard = UIStoryboard(name: PushBoard, bundle: nil)
        guard let pushTab = pushboard.instantiateViewController(withIdentifier: PushBoard) as? PushListViewController else { return }
        
        let setBoard = UIStoryboard(name: SettingBoard, bundle: nil)
        guard let settingTab = setBoard.instantiateViewController(withIdentifier: SettingBoard) as? SettingViewController else { return }
        
        self.viewControllers = [mainTab, categoryTab, pushTab, settingTab]
        
        guard let vcList = self.viewControllers else {
            return
        }
        for (i, icon) in iconList.enumerated() {
            let currentTab = vcList[i]
            let tabBarItem = UITabBarItem(
                title: nil,
                image: UIImage(systemName: icon)?.withConfiguration(boldConfig).withTintColor(.label, renderingMode: .alwaysOriginal),
                selectedImage: UIImage(systemName: icon)?.withConfiguration(boldConfig).withTintColor(.systemIndigo, renderingMode: .alwaysOriginal)
            )
            currentTab.tabBarItem = tabBarItem
        }
    }
    // 탭 아이콘 활성화 컨트롤
    func controllTabItem(_ isOn:Bool) {
        guard let list = viewControllers else { return }
        for vc in list {
            vc.tabBarItem.isEnabled = isOn
        }
    }
}

extension CustomTabBarController : UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // 탭 전환 시
        SystemManager.shared.setTheme(viewController)
    }
}
