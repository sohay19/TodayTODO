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
    //
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelNilMsg: UILabel!
    //
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnSelectAll: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    //
    @IBOutlet weak var segmentedController: CustomSegmentControl!
    //
    @IBOutlet weak var pushTable: UITableView!
    @IBOutlet weak var editView: UIView!
    
    var pushList:[AlarmInfo] = []
    var heightConstraint:NSLayoutConstraint?
    var heightOrigin:CGFloat = 60
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.navigationItem.setHidesBackButton(true, animated: false)
        //
        pushTable.delegate = self
        pushTable.dataSource = self
        //
        pushTable.allowsSelectionDuringEditing = true
        pushTable.allowsMultipleSelectionDuringEditing = true
        pushTable.allowsFocusDuringEditing = true
        //
        for const in editView.constraints {
            if const.identifier == "height" {
                heightConstraint = const
                break
            }
        }
        //
        initUI()
        initCell()
        //
        initRefreshController()
        //메뉴
        SystemManager.shared.openMenu(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        //
        if pushTable.isEditing {
            changeEditMode()
        }
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
        editView.backgroundColor = .clear
        controllEditView(false)
        //
        pushTable.backgroundColor = .clear
        pushTable.separatorInsetReference = .fromCellEdges
        pushTable.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pushTable.separatorColor = .label
        //
        labelDate.font = UIFont(name: E_N_Font_E, size: MenuFontSize)
        labelNilMsg.font = UIFont(name: K_Font_R, size: K_FontSize)
        //
        btnEdit.setImage(UIImage(systemName: "scissors", withConfiguration: swipeConfig), for: .normal)
        //
        imgUnderline.alpha = 0.3
        //
        changeTitle()
    }
    //
    func initCell() {
        let nibName = UINib(nibName: "PushCell", bundle: nil)
        pushTable.register(nibName, forCellReuseIdentifier: "PushCell")
    }
    //
    func controllEditView(_ isOn:Bool) {
        guard let heightConstraint = heightConstraint else {
            return
        }
        heightConstraint.constant = isOn ? heightOrigin : 0
        btnSelectAll.isHidden = isOn ? false : true
        btnDelete.isHidden = isOn ? false : true
    }
    //
    func changeTitle() {
        switch segmentedController.selectedSegmentIndex {
        case 0:
            labelDate.text = "Today Push"
            imgUnderline.image = UIImage(named: Underline_Pink)
        case 1:
            labelDate.text = "All Push"
            imgUnderline.image = UIImage(named: Underline_Indigo)
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
        // 리스트 삭제
        pushList.remove(at: indexPath.row)
        pushTable.reloadData()
    }
}

//MARK: - Button Event
extension PushListViewController {
    //SegmentedControl
    @IBAction func changeSegment(_ sender:UISegmentedControl) {
        beginAppearanceTransition(true, animated: true)
        viewWillAppear(true)
    }
    //
    @IBAction func changeDailyTaskEditMode(_ sender:UIButton) {
        if pushList.count == 0 {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "편집 가능한 알림이 없습니다")
            return
        }
        changeEditMode()
    }
    private func changeEditMode() {
        if pushTable.isEditing {
            btnEdit.setImage(UIImage(systemName: "scissors", withConfiguration: swipeConfig), for: .normal)
            pushTable.setEditing(false, animated: false)
            for cell in pushTable.visibleCells {
                cell.selectionStyle = .none
            }
            controllEditView(false)
        } else {
            btnEdit.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right", withConfiguration: swipeConfig), for: .normal)
            pushTable.setEditing(true, animated: false)
            for cell in pushTable.visibleCells {
                cell.selectionStyle = .default
            }
            controllEditView(true)
        }
    }
    @IBAction func clickSelectAll(_ sender:UIButton) {
        guard let list = pushTable.indexPathsForVisibleRows else {
            return
        }
        if let selectedList = pushTable.indexPathsForSelectedRows {
            if list.count == selectedList.count {
                for index in list {
                    pushTable.deselectRow(at: index, animated: true)
                }
                return
            }
        }
        for index in list {
            pushTable.selectRow(at: index, animated: true, scrollPosition: .none)
        }
    }
    @IBAction func clickDelete(_ sender:UIButton) {
        guard let list = pushTable.indexPathsForSelectedRows else {
            return
        }
        for index in list {
            deletePush(index)
        }
        controllEditView(false)
    }
}
