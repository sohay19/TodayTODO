//
//  SettingViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit
import FirebaseAuth

class SettingViewController: UIViewController {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelTableTitle: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelBackupDate: UILabel!
    //
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnBackup: UIButton!
    
    
    private let cloudManager = CloudManager()
    
    var dataList:[(name:String, url:URL)] = []
    var isRefresh = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        tableView.delegate = self
        tableView.dataSource = self
        //
        initUI()
        initCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        //백업파일 날짜로드
        updateCloud(label: labelBackupDate)
        loadData()
    }
}

//MARK: - Func
extension SettingViewController {
    func initUI() {
        // 배경 설정
        let backgroundView = UIImageView(frame: UIScreen.main.bounds)
        backgroundView.image = UIImage(named: BackgroundImage)
        view.insertSubview(backgroundView, at: 0)
        //폰트 설정
        labelTitle.font = UIFont(name: E_N_Font_E, size: MenuFontSize)
        labelDate.font = UIFont(name: K_Font_B, size: K_FontSize + 3.0)
        labelBackupDate.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelTableTitle.font = UIFont(name: K_Font_B, size: K_FontSize + 3.0)
        labelTitle.textColor = .label
        labelDate.textColor = .label
        labelBackupDate.textColor = .label
        labelTableTitle.textColor = .label
        //
        tableView.allowsSelection = false
        tableView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        tableView.layer.cornerRadius = 5
        tableView.separatorColor = .systemFill
        //
        btnBackup.contentMode = .center
        btnBackup.setImage(UIImage(systemName: "tray.and.arrow.down.fill", withConfiguration: mediumConfig), for: .normal)
    }
    //
    func initCell() {
        let nibName = UINib(nibName: "BackUpCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "BackUpCell")
    }
    //
    func loadData() {
        dataList = getAllBackupFile()
        tableView.reloadData()
        //
        SystemManager.shared.closeLoading()
        if isRefresh {
            endAppearanceTransition()
            isRefresh = false
        }
    }
}

//MARK: - iCloud
extension SettingViewController {
    //
    func getAllBackupFile() -> [(String, URL)] {
        cloudManager.realmUrl = DataManager.shared.getRealmURL()
        return cloudManager.getAllBackupFile()
    }
    //
    func updateCloud(label:UILabel) {
        cloudManager.realmUrl = DataManager.shared.getRealmURL()
        cloudManager.updateDate(label)
    }
    //
    func iCloudBackup(_ vc:UIViewController) {
        cloudManager.realmUrl = DataManager.shared.getRealmURL()
        cloudManager.backUpFile(vc)
    }
    //
    func iCloudLoadFile(_ vc:UIViewController, _ url:URL) {
        cloudManager.realmUrl = DataManager.shared.getRealmURL()
        cloudManager.loadBackupFile(vc, url)
    }
    func iCloudLoadRecentlyFile(_ vc:UIViewController) {
        cloudManager.realmUrl = DataManager.shared.getRealmURL()
        cloudManager.loadRecentlyBackupFile(vc)
    }
    //
    func deleteiCloudBackupFile(_ url:URL) {
        cloudManager.realmUrl = DataManager.shared.getRealmURL()
        cloudManager.deleteBackupFile(url)
    }
    func deleteiCloudAllBackupFile() {
        cloudManager.realmUrl = DataManager.shared.getRealmURL()
        cloudManager.deleteAllBackupFile()
    }
    func deleteAllFile() {
        deleteiCloudAllBackupFile()
        DataManager.shared.deleteRealm()
        DataManager.shared.deleteAllAlarmPush()
    }
}

//MARK: - Func
extension SettingViewController {
    func updateDate() {
        updateCloud(label: labelBackupDate)
    }
    
    func loadBackupFile(_ indexPath:IndexPath) {
        let url = self.dataList[indexPath.row].url
        iCloudLoadFile(self, url)
    }
    
    func deleteBackupFile(_ indexPath:IndexPath)  {
        let url = self.dataList[indexPath.row].url
        deleteiCloudBackupFile(url)
        //
        dataList.remove(at: indexPath.row)
        tableView.reloadData()
        updateDate()
    }
}

//MARK: - Button Event
extension SettingViewController {
    //데이터 백업
    @IBAction func backData(_ sender: Any) {
        iCloudBackup(self)
        isRefresh = true
        beginAppearanceTransition(true, animated: true)
    }
    //refresh
    @IBAction func clickRefresh(_ sender: Any) {
        updateDate()
    }
    //
    @IBAction func removeAllFile(_ sender: Any) {
        deleteAllFile()
        dataList.removeAll()
        tableView.reloadData()
        
    }
}

//MARK: - TableView
extension SettingViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let backUpCell = tableView.dequeueReusableCell(withIdentifier: "BackUpCell", for: indexPath) as? BackUpCell else {
            return UITableViewCell()
        }
        let backUpData = dataList[indexPath.row]
        backUpCell.labelDate.text = backUpData.name
        
        return backUpCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    //MARK: - Swipe
    //오른쪽 스와이프
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //
        let load = UIContextualAction(style: .normal, title: "") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.loadBackupFile(indexPath)
            success(true)
        }
        load.image = UIImage(systemName: "tray.and.arrow.up.fill", withConfiguration: regularConfig)
        load.backgroundColor = .systemIndigo.withAlphaComponent(0.5)
        //
        let delete = UIContextualAction(style: .normal, title: "") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.deleteBackupFile(indexPath)
            success(true)
        }
        delete.image = UIImage(systemName: "trash.fill", withConfiguration: regularConfig)
        delete.backgroundColor = .defaultPink!.withAlphaComponent(0.5)
        //index = 0, 오른쪽
        return UISwipeActionsConfiguration(actions:[delete, load])
    }
}
