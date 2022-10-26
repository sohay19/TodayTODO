//
//  PushListViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/21.
//

import Foundation
import UIKit


class PushListViewController : UIViewController {
    @IBOutlet weak var pushTable: UITableView!
    
    
    var pushList:[AlarmInfo] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.navigationItem.setHidesBackButton(true, animated: false)
        //
        pushTable.delegate = self
        pushTable.dataSource = self
        //
        initRefreshController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //
        loadPushData()
        //
        DispatchQueue.main.async {
            SystemManager.shared.closeLoading()
        }
    }
}


//MARK: - Func
extension PushListViewController {
    func loadPushData() {
        let pushlist = RealmManager.shared.getAllAlarmInfo()
        pushList = pushlist.sorted { $0.alarmTime < $1.alarmTime }
        pushTable.reloadData()
    }
    //refresh controller 초기세팅
    func initRefreshController() {
        //
        let pushRefreshControl = UIRefreshControl()
        pushRefreshControl.addTarget(self, action: #selector(refreshPushView), for: .valueChanged)
        //초기화
        pushRefreshControl.endRefreshing()
        pushTable.refreshControl = pushRefreshControl
    }
    @objc func refreshPushView() {
        pushTable.refreshControl?.endRefreshing()
        pushTable.reloadData()
    }
    //
    func deletePush(_ indexPath:IndexPath) {
        
    }
}

//MARK: - Button Event
extension PushListViewController {
    @IBAction func clickSideMenu(_ sender:Any) {
        SystemManager.shared.openSideMenu(self)
    }
}
