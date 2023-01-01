//
//  BackupViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/25.
//

import UIKit
import FirebaseAuth

class BackupViewController: UIViewController {
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelTableTitle: UILabel!
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelBackupDate: UILabel!
    //
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var btnBackup: UIButton!
    @IBOutlet weak var btnAllDelete: UIButton!
    
    
    private let cloudManager = CloudManager()
    
    var segmentControl = CustomSegmentControl()
    var dataList:[(name:String, url:URL)] = []
    var isRefresh = false
    //
    let backgroundView = UIImageView(frame: UIScreen.main.bounds)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        tableView.delegate = self
        tableView.dataSource = self
        //
        view.insertSubview(backgroundView, at: 0)
        initCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        //
        initUI()
        //백업파일 날짜로드
        updateCloud(label: labelBackupDate)
        loadData()
    }
}

//MARK: - Func
extension BackupViewController {
    func initUI() {
        // 배경 설정
        backgroundView.image = UIImage(named: BackgroundImage)
        line.backgroundColor = .label
        //폰트 설정
        labelTitle.font = UIFont(name: E_Font_B, size: E_FontSize)
        labelDate.font = UIFont(name: K_Font_B, size: K_FontSize + 3.0)
        labelBackupDate.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelTableTitle.font = UIFont(name: K_Font_B, size: K_FontSize + 3.0)
        labelInfo.font = UIFont(name: K_Font_R, size: K_FontSize - 4.0)
        labelInfo.textColor = .gray
        labelDate.textColor = .label
        labelBackupDate.textColor = .label
        labelTableTitle.textColor = .label
        //
        backView.backgroundColor = .clear
        backView.layer.cornerRadius = 5
        backView.layer.borderColor = UIColor.gray.cgColor
        backView.layer.borderWidth = 0.2
        //
        tableView.backgroundColor = .clear
        tableView.sectionHeaderTopPadding = 0
        tableView.sectionFooterHeight = 0
        tableView.sectionHeaderHeight = 0
        tableView.separatorInsetReference = .fromCellEdges
        tableView.separatorColor = .clear
        tableView.showsVerticalScrollIndicator = false
        //
        btnBack.setImage(UIImage(systemName: "chevron.backward", withConfiguration: mediumConfig), for: .normal)
        btnBack.tintColor = .label
        btnRefresh.setImage(UIImage(systemName: "arrow.clockwise", withConfiguration: mediumConfig), for: .normal)
        btnRefresh.contentMode = .center
        btnBackup.setImage(UIImage(systemName: "icloud.and.arrow.up", withConfiguration: mediumConfig), for: .normal)
        btnBackup.contentMode = .center
        btnBackup.titleLabel?.font = UIFont(name: K_Font_B, size: K_FontSize)
        btnBackup.backgroundColor = .lightGray.withAlphaComponent(0.1)
        btnBackup.layer.cornerRadius = 5
        btnBackup.layer.borderWidth = 0.3
        btnBackup.layer.borderColor = UIColor.gray.cgColor
        btnAllDelete.setTitle("백업리스트 모두 삭제", for: .normal)
        btnAllDelete.contentMode = .center
        btnAllDelete.titleLabel?.font = UIFont(name: K_Font_B, size: K_FontSize)
        btnAllDelete.backgroundColor = .lightGray.withAlphaComponent(0.1)
        btnAllDelete.layer.cornerRadius = 5
        btnAllDelete.layer.borderWidth = 0.3
        btnAllDelete.layer.borderColor = UIColor.gray.cgColor
    }
    private func refresh() {
        isRefresh = true
        beginAppearanceTransition(true, animated: true)
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
extension BackupViewController {
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
        refresh()
    }
    //
    func iCloudLoadFile(_ vc:UIViewController, _ url:URL) {
        cloudManager.realmUrl = DataManager.shared.getRealmURL()
        cloudManager.loadBackupFile(vc, url)
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
        //백업 파일 삭제
        deleteiCloudAllBackupFile()
    }
}

//MARK: - Func
extension BackupViewController {
    func updateDate() {
        updateCloud(label: labelBackupDate)
    }
    // 백업 파일 로드
    func loadBackupFile(_ indexPath:IndexPath) {
        PopupManager.shared.openYesOrNo(self, title: "백업 파일 로드", msg: "해당 파일로 덮어쓰시겠습니까?",
                                        completeYes: { [self] _ in
            SystemManager.shared.openLoading()
            let url = self.dataList[indexPath.row].url
            iCloudLoadFile(self, url)
        }, completeNo: { _ in SystemManager.shared.closeLoading() })
    }
    //
    func deleteBackupFile(_ indexPath:IndexPath)  {
        PopupManager.shared.openYesOrNo(self, title: "백업 파일 삭제", msg: "해당 파일을 삭제하시겠습니까?",
                                        completeYes: { [self] _ in
            let url = self.dataList[indexPath.row].url
            deleteiCloudBackupFile(url)
            //
            dataList.remove(at: indexPath.row)
            tableView.reloadData()
            updateDate()
        })
    }
}

//MARK: - Button Event
extension BackupViewController {
    //데이터 백업
    @IBAction func backData(_ sender: Any) {
        iCloudBackup(self)
    }
    //refresh
    @IBAction func clickRefresh(_ sender: Any) {
        updateDate()
    }
    //
    @IBAction func removeAllFile(_ sender: Any) {
        PopupManager.shared.openYesOrNo(self, title: "백업 파일 모두 삭제", msg: "정말 삭제하시곘습니까?") { [self] _ in
            deleteAllFile()
            dataList.removeAll()
            tableView.reloadData()
        }
    }
    @IBAction func clickBack(_ sender:Any) {
        guard let navigationController = self.navigationController as? CustomNavigationController else { return }
        navigationController.popViewController()
    }
}

//MARK: - TableView
extension BackupViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataList.count
    }
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let backUpCell = tableView.dequeueReusableCell(withIdentifier: "BackUpCell", for: indexPath) as? BackUpCell else {
            return UITableViewCell()
        }
        let backUpData = dataList[indexPath.section]
        backUpCell.inputCell(backUpData.name)
        
        return backUpCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 6
    }
    //MARK: - Event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loadBackupFile(indexPath)
    }
    //MARK: - Swipe
    //오른쪽 스와이프
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.deleteBackupFile(indexPath)
            success(true)
        }
        delete.image = UIImage(systemName: "trash.fill", withConfiguration: mediumConfig)
        delete.backgroundColor = .defaultPink!
        //index = 0, 오른쪽
        return UISwipeActionsConfiguration(actions:[delete])
    }
}
