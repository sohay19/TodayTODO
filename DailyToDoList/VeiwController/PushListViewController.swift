//
//  PushListViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/21.
//

import Foundation
import UIKit


class PushListViewController : UIViewController {
    @IBOutlet weak var imgUnderline: UIImageView!
    @IBOutlet weak var pushTable: UITableView!
    @IBOutlet weak var segmentedController: CustomSegmentControl!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var labelNilMsg: UILabel!
    
    var pushList:[AlarmInfo] = []
    var heightConstraint:NSLayoutConstraint?
    var bottomConstraint:NSLayoutConstraint?
    var heightOriginValue:CGFloat = 0.0
    var bottomOriginValue:CGFloat = 0.0
    var heightChangeValue:CGFloat = 39.0
    var bottomChangeValue:CGFloat = 6.0
    
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
            changeTitle()
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
        labelNilMsg.isHidden = pushList.count == 0 ? false : true
        pushTable.reloadData()
        //
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            SystemManager.shared.closeLoading()
        }
    }
    //
    func initUI() {
        // 배경 설정
        let backgroundView = UIImageView(frame: UIScreen.main.bounds)
        backgroundView.image = UIImage(named: BackgroundImage)
        view.insertSubview(backgroundView, at: 0)
        //
        pushTable.backgroundColor = .clear
        pushTable.separatorInsetReference = .fromCellEdges
        pushTable.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pushTable.separatorColor = .label
        //
        labelDate.font = UIFont(name: E_N_Font, size: E_N_FontSize)
        labelNilMsg.font = UIFont(name: MenuKORFont, size: MenuKORFontSize)
        //
        imgUnderline.alpha = 0.3
        //
        for const in imgUnderline.constraints {
            if const.identifier == "height" {
                heightConstraint = const
                heightOriginValue = const.constant
            }
        }
        for const in view.constraints {
            if const.identifier == "bottom" {
                bottomConstraint = const
                bottomOriginValue = const.constant
                return
            }
        }
        //
        changeTitle()
    }
    //
    func changeTitle() {
        switch segmentedController.selectedSegmentIndex {
        case 0:
            labelDate.text = "Today Push"
            imgUnderline.image = UIImage(named: Underline_Pink)
            guard let heightConstraint = heightConstraint, let bottomConstraint = bottomConstraint else {
                return
            }
            heightConstraint.constant = heightOriginValue
            bottomConstraint.constant = bottomOriginValue
        case 1:
            labelDate.text = "All Push"
            imgUnderline.image = UIImage(named: Underline_Indigo)
            guard let heightConstraint = heightConstraint, let bottomConstraint = bottomConstraint else {
                return
            }
            heightConstraint.constant = heightChangeValue
            bottomConstraint.constant = bottomChangeValue
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
        let id = pushList[indexPath.row].taskId
        guard let task = RealmManager.shared.getTaskData(id) else {
            return
        }
        let newTask = EachTask(id: task.id, taskDay: task.taskDay, category: task.category, title: task.title, memo: task.memo, repeatType: task.repeatType, weekDay: task.getWeekDayList(), weekOfMonth: task.weekOfMonth, isEnd: task.isEnd, taskEndDate: task.taskEndDate, isAlarm: false, alarmTime: "", isDone: task.isDone)
        // task data 업데이트
        RealmManager.shared.updateTaskDataForiOS(newTask)
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
    @IBAction func changeSegment(_ sender:UISegmentedControl) {
        viewWillAppear(true)
    }
    //
    @IBAction func changeDailyTaskEditMode(_ sender:UIButton) {
        if pushList.count == 0 {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "현재 예정된 푸시가 없어요")
            return
        }
        changeEditMode()
    }
    private func changeEditMode() {
        if pushTable.isEditing {
            btnEdit.setImage(UIImage(systemName: "scissors"), for: .normal)
            pushTable.setEditing(false, animated: false)
        } else {
            btnEdit.setImage(UIImage(systemName: "return"), for: .normal)
            pushTable.setEditing(true, animated: false)
        }
    }
}
