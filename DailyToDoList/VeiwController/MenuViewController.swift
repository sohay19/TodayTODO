//
//  MenuViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/11.
//

import Foundation
import UIKit

class MenuViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //뒤로 버튼 없애기
        self.navigationItem.setHidesBackButton(true, animated: false)
        //
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

//MARK: - init
extension MenuViewController {
    func initUI() {
        view.backgroundColor = .clear
    }
}

//MARK: - Button
extension MenuViewController {
    @IBAction func clickBtnTODO(_ sender:Any) {
        dismiss(animated: true)
        SystemManager.shared.moveMain()
    }
    //
    @IBAction func clickBtnPushList(_ sender:Any) {
        dismiss(animated: true)
        SystemManager.shared.movePush()
    }
    //
    @IBAction func clickBtnBackup(_ sender:Any) {
        dismiss(animated: true)
        SystemManager.shared.moveBackup()
    }
}
