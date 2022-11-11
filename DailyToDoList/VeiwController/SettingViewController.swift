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
        tableView.delegate = self
        tableView.dataSource = self
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
        labelDate.font = UIFont(name: K_Font_B, size: K_FontSize)
        labelBackupDate.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelTableTitle.font = UIFont(name: K_Font_B, size: K_FontSize)
        //
        imgUnderline.image = UIImage(named: Underline_Pink)
        imgUnderline.alpha = 0.5
        imgUnderline_table.image = UIImage(named: Underline_Pink)
        imgUnderline_table.alpha = 0.5
        //
        tableView.backgroundColor = .clear
        tableView.layer.borderColor = UIColor.secondaryLabel.cgColor
        tableView.layer.borderWidth = 0.5
        tableView.layer.cornerRadius = 5
        tableView.separatorColor = .label
        tableView.rowHeight = 49
    }
    
    func loadData() {
        dataList = DataManager.shared.getAllBackupFile()
        tableView.reloadData()
        //
        SystemManager.shared.closeLoading()
    }
}

//MARK: - Func
extension SettingViewController {
    func updateDate() {
        DataManager.shared.updateCloud(label: labelBackupDate)
    }
    
    func loadBackupFile(_ indexPath:IndexPath) {
        let url = self.dataList[indexPath.row].url
        DataManager.shared.iCloudLoadFile(self, url)
    }
    
    func deleteBackupFile(_ indexPath:IndexPath)  {
        let url = self.dataList[indexPath.row].url
        DataManager.shared.deleteiCloudBackupFile(url)
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
        DataManager.shared.iCloudBackup(self)
        beginAppearanceTransition(true, animated: true)
        viewWillAppear(true)
    }
    //refresh
    @IBAction func clickRefresh(_ sender: Any) {
        updateDate()
    }
    //
    @IBAction func removeAllFile(_ sender: Any) {
        DataManager.shared.deleteAllFile()
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
        guard let backUpCell = tableView.dequeueReusableCell(withIdentifier: "backUpCell", for: indexPath) as? BackUpCell else {
            return UITableViewCell()
        }
        let backUpData = dataList[indexPath.row]
        backUpCell.labelDate.text = backUpData.name
        
        return backUpCell
    }
    //MARK: - Swipe
    //오른쪽 스와이프
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //
        let load = UIContextualAction(style: .normal, title: "") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.loadBackupFile(indexPath)
            success(true)
        }
        load.image = UIImage(systemName: "tray.and.arrow.up.fill")
        load.backgroundColor = .systemIndigo.withAlphaComponent(0.5)
        //
        let delete = UIContextualAction(style: .normal, title: "") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.deleteBackupFile(indexPath)
            success(true)
        }
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = .defaultPink!.withAlphaComponent(0.5)
        //index = 0, 오른쪽
        return UISwipeActionsConfiguration(actions:[delete, load])
    }
}
