//
//  SideMenuViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/20.
//

import Foundation
import UIKit

class SideMenuViewController : UIViewController {
    @IBOutlet weak var btnTODO: UIButton!
    @IBOutlet weak var btnPush: UIButton!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var btnBackup: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        initUI()
    }
    
    func initUI() {
        // 배경 설정
        let backgroundView = UIImageView(frame: UIScreen.main.bounds)
        backgroundView.image = UIImage(named: BlackBackImage)
        view.insertSubview(backgroundView, at: 0)
        // 폰트 설정
        btnTODO.titleLabel?.font = UIFont(name: SideMenuFont, size: SideMenuFontSize + 6.0)
        btnPush.titleLabel?.font = UIFont(name: SideMenuFont, size: SideMenuFontSize + 6.0)
        btnCategory.titleLabel?.font = UIFont(name: SideMenuFont, size: SideMenuFontSize + 6.0)
        btnBackup.titleLabel?.font = UIFont(name: SideMenuFont, size: SideMenuFontSize + 6.0)
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
