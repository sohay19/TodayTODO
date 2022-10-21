//
//  SideMenuViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/20.
//

import Foundation
import UIKit

class SideMenuViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SideMenuViewController {
    @IBAction func clickBtnTODO(_ sender:Any) {
        SystemManager.shared.moveMain()
    }
    //
    @IBAction func clickBtnPushList(_ sender:Any) {
        SystemManager.shared.movePush()
    }
    //
    @IBAction func clickBtnBackup(_ sender:Any) {
        SystemManager.shared.moveBackup()
    }
}
