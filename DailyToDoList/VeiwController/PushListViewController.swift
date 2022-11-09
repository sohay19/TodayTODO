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
    @IBOutlet weak var segmentedController: CustomSegmentControl!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var btnDeleteAll: UIButton!
    
    var pushList:[AlarmInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.navigationItem.setHidesBackButton(true, animated: false)
        //
        pushTable.delegate = self
        pushTable.dataSource = self
        //
        initUI()
        //
        initRefreshController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SystemManager.shared.openLoading()
        DispatchQueue.main.async { [self] in 
            //
            loadPushData()
            //
            changeSegment()
        }
    }
}


//MARK: - Func
extension PushListViewController {
    func loadPushData() {
        switch segmentedController.selectedSegmentIndex {
        case 0:
            let pushlist = RealmManager.shared.getTodayAlarmInfo()
            pushList = pushlist.sorted { $0.alarmTime < $1.alarmTime }
        case 1:
            let pushlist = RealmManager.shared.getAllAlarmInfo()
            pushList = pushlist.sorted { $0.alarmTime < $1.alarmTime }
        default:
            break
        }
        //
        pushTable.reloadData()
        //
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            SystemManager.shared.closeLoading()
        }
    }
    //
    func initUI() {
        //
        labelDate.font = UIFont(name: MenuKORFont, size: MenuKORFontSize)
        btnDeleteAll.titleLabel?.font = UIFont(name: MenuKORFont, size: MenuKORFontSize - 6.0)
        //
        changeSegment()
    }
    //
    func changeSegment() {
        switch segmentedController.selectedSegmentIndex {
        case 0:
            labelDate.text = "오늘 예정된 알람"
        case 1:
            labelDate.text = "모든 예정된 알람"
        default:
            break
        }
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
        // 알람만 삭제
        PushManager.shared.deletePush(pushList[indexPath.row].alarmIdList.map{$0})
        // 리스트 삭제
        pushList.remove(at: indexPath.row)
        pushTable.reloadData()
    }
}

//MARK: - Button Event
extension PushListViewController {
    @IBAction func clickSideMenu(_ sender:Any) {
        SystemManager.shared.openSideMenu(self)
    }
    //SegmentedControl
    @IBAction func changeSegment(_ sender:UISegmentedControl) {//
        viewWillAppear(true)
    }
    //
    @IBAction func deleteAllNoti(_ sender:Any) {
        PushManager.shared.deleteAllPush()
        RealmManager.shared.deleteAllAlarm()
    }
}
