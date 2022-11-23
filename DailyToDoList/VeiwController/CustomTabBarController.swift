//
//  CustomTabBarController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/18.
//

import Foundation
import UIKit

class CustomTabBarController : UITabBarController {
    
    let iconList:[String] = ["calendar", "list.bullet", "alarm.fill", "icloud.fill"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.delegate = self
        self.tabBar.backgroundColor = .clear
        //
        initTabBar()
    }
}

extension CustomTabBarController : UITabBarControllerDelegate {
    func initTabBar() {
        guard let mainTab = self.storyboard!.instantiateViewController(withIdentifier: "MainVC") as? MainViewController else { return }
        
        let cBoard = UIStoryboard(name: categoryBoard, bundle: nil)
        guard let categoryTab = cBoard.instantiateViewController(withIdentifier: categoryBoard) as? CategoryViewController else { return }
        
        let pushBoard = UIStoryboard(name: pushListBoard, bundle: nil)
        guard let pushTab = pushBoard.instantiateViewController(withIdentifier: pushListBoard) as? PushListViewController else { return }
        
        let setBoard = UIStoryboard(name: settingBoard, bundle: nil)
        guard let settingTab = setBoard.instantiateViewController(withIdentifier: settingBoard) as? SettingViewController else { return }
        
        self.viewControllers = [mainTab, categoryTab, pushTab, settingTab]
        
        guard let vcList = self.viewControllers else {
            return
        }
        for (i, icon) in iconList.enumerated() {
            let currentTab = vcList[i]
            let tabBarItem = UITabBarItem(
                title: nil,
                image: UIImage(systemName: icon)?.withConfiguration(boldConfig).withTintColor(.label, renderingMode: .alwaysOriginal),
                selectedImage: UIImage(systemName: icon)?.withConfiguration(boldConfig).withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            )
            currentTab.tabBarItem = tabBarItem
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        print("\(viewController.tabBarItem.title)")
    }
}
