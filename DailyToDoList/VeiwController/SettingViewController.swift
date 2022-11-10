//
//  SettingViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit
import FirebaseAuth

class SettingViewController: UIViewController {
    @IBOutlet weak var imgUnderline: UIImageView!
    @IBOutlet weak var imgUnderline_table: UIImageView!
    //
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelTableTitle: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelBackupDate: UILabel!
    //
    @IBOutlet weak var tableView: UITableView!
    
    var dataList:[(name:String, url:URL)] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.navigationItem.setHidesBackButton(true, animated: false)
        //
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        //백업파일 날짜로드
        DataManager.shared.updateCloud(label: labelBackupDate)
        //
        DispatchQueue.main.async { [self] in
            loadData()
        }
    }
}

//MARK: - Func
extension SettingViewController {
    func initUI() {
        // 배경 설정
        let backgroundView = UIImageView(frame: UIScreen.main.bounds)
        backgroundView.image = UIImage(named: LastPageImage)
        view.insertSubview(backgroundView, at: 0)
        //폰트 설정
        labelTitle.font = UIFont(name: SideMenuFont, size: SideMenuFontSize)
        labelDate.font = UIFont(name: MenuKORFont, size: MenuKORFontSize + 6.0)
        labelBackupDate.font = UIFont(name: MenuKORFont, size: MenuKORFontSize)
        labelTableTitle.font = UIFont(name: MenuKORFont, size: MenuKORFontSize + 6.0)
        //
        imgUnderline.image = UIImage(named: Underline_Pink)
        imgUnderline.alpha = 0.5
        imgUnderline_table.image = UIImage(named: Underline_Pink)
        imgUnderline_table.alpha = 0.5
        //
        tableView.backgroundColor = .clear
    }
    
    func loadData() {
        dataList = DataManager.shared.getAllBackupFile()
        print("dataList.count = \(dataList.count)")
        //
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

//MARK: - TableView
extension SettingViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let backUpCell = tableView.dequeueReusableCell(withIdentifier: "backUpCell", for: indexPath) as? PushCell else {
            return UITableViewCell()
        }
//        let backUpData =
//        guard let backUpData = backUpData else {
//            return UITableViewCell()
//        }
        
        return backUpCell
    }
    //MARK: - Swipe
    //오른쪽 스와이프
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //
        let load = UIContextualAction(style: .normal, title: "load") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
//            self.deletePush(indexPath)
            success(true)
        }
        load.backgroundColor = .systemIndigo
        //
        let delete = UIContextualAction(style: .normal, title: "delete") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
//            self.deletePush(indexPath)
            success(true)
        }
        delete.backgroundColor = .defaultPink
        //index = 0, 오른쪽
        return UISwipeActionsConfiguration(actions:[delete, load])
    }
    //MARK: - Event
    //cell 클릭 Event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
