//
//  CustomSideMenuNavigation.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/20.
//

import Foundation
import SideMenu
import UIKit

class CustomSideMenuNavigation : SideMenuNavigationController {
    var beforeVC:UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presentationStyle = .viewSlideOut
        self.leftSide = true
        self.statusBarEndAlpha = 0
    }
}
