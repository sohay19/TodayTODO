//
//  SettingViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit
import FirebaseAuth

class SettingViewController: UIViewController {
    @IBOutlet weak var labelBackupDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //백업파일 날짜로드
        DataManager.shared.updateCloud(label: labelBackupDate)
        SystemManager.shared.closeLoading()
    }
}


//MARK: - Button Event
extension SettingViewController {
    //데이터 백업
    @IBAction func backData(_ sender: Any) {
        DataManager.shared.iCloudBackup(self)
    }
    //데이터 로드
    @IBAction func loadData(_ sender: Any) {
        DataManager.shared.iCloudLoadFile(self)
    }
    //refresh
    @IBAction func clickRefresh(_ sender: Any) {
        DataManager.shared.updateCloud(label: labelBackupDate)
    }
    
    @IBAction func removeBackupFile(_ sender: Any) {
        DataManager.shared.deleteiCloudBackupFile()
    }
    
    @IBAction func removeAllFile(_ sender: Any) {
        DataManager.shared.deleteAllFile()
        guard let navigation = self.navigationController as? CustomNavigationController else {
            return
        }
        navigation.popToRootViewController()
    }
    @IBAction func clickSideMenu(_ sender: Any) {
        SystemManager.shared.openSideMenu(self)
    }
}
