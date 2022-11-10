//
//  CustomSideMenuNavigation.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/10.
//

import Foundation
import UIKit
import SideMenu

class CustomSideMenuNavigation: SideMenuNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.presentationStyle = .viewSlideOut
        self.leftSide = true
        self.statusBarEndAlpha = 0
        self.isNavigationBarHidden = true
    }
}
