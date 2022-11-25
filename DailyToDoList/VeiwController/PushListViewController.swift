//
//  PushListViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/21.
//

import Foundation
import UIKit


class PushListViewController : UIViewController {
    @IBOutlet weak var imgClock: UIImageView!
    //
    @IBOutlet weak var labelNilMsg: UILabel!
    //
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnSelectAll: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    //
    @IBOutlet weak var pushTable: UITableView!
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var editView: UIView!
    
    var segmentControl = CustomSegmentControl()
    
    var taskList:[String:[EachTask]] = [:]
    var categoryList:[String] = []
    var heightConstraint:NSLayoutConstraint?
    var heightOrigin:CGFloat = 60
    var isRefresh = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        pushTable.delegate = self
        pushTable.dataSource = self
        //
        pushTable.allowsSelectionDuringEditing = true
        pushTable.allowsMultipleSelectionDuringEditing = true
        pushTable.allowsFocusDuringEditing = true
        //
        initConstraints()
        //
        initUI()
        initCell()
        //
        initRefreshController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        loadPushData()
        changeEditMode(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //
        segmentControl.selectedSegmentIndex = 0
        changeEditMode(false)
    }
}

//MARK: - init
extension PushListViewController {
    //
    func initUI() {
        // 배경 설정
        let backgroundView = UIImageView(frame: UIScreen.main.bounds)
        backgroundView.image = UIImage(named: BackgroundImage)
        view.insertSubview(backgroundView, at: 0)
        //
        segmentView.backgroundColor = .clear
        addSegmentcontrol()
        //
        editView.backgroundColor = .clear
        //
        pushTable.sectionHeaderTopPadding = 0
        pushTable.sectionHeaderHeight = 30
        pushTable.sectionFooterHeight = 30
        pushTable.backgroundColor = .clear
        pushTable.separatorInsetReference = .fromCellEdges
        pushTable.separatorColor = .label
        pushTable.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //
        labelNilMsg.font = UIFont(name: K_Font_R, size: K_FontSize + 3.0)
        //
        btnEdit.contentMode = .center
    }
    //
    private func addSegmentcontrol() {
        let segment = CustomSegmentControl(items: ["Today Alarm", "More Alarm"])
        segment.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: segmentView.frame.size)
        segment.addTarget(self, action: #selector(changeSegment(_:)), for: .valueChanged)
        segment.selectedSegmentIndex = 0
        segmentControl = segment
        segmentView.addSubview(segment)
    }
    private func initConstraints() {
        for const in editView.constraints {
            if const.identifier == "height" {
                heightConstraint = const
                break
            }
        }
    }
    //
    func initCell() {
        let nibName = UINib(nibName: "PushCell", bundle: nil)
        pushTable.register(nibName, forCellReuseIdentifier: "PushCell")
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
}

//MARK: - Func
extension PushListViewController {
    // data reset
    func resetTask() {
        taskList = [:]
        categoryList = []
    }
    func loadPushData() {
        DispatchQueue.main.async { [self] in
            resetTask()
            //
            switch segmentControl.selectedSegmentIndex {
            case 0:
                DataManager.shared.getTodayPush(loadPushList(_:))
            case 1:
                DataManager.shared.getAllPush(loadPushList(_:))
            default:
                break
            }
        }
    }
    private func loadPushList(_ requestList:[UNNotificationRequest]) {
        DispatchQueue.main.sync { [self] in
            for request in requestList {
                guard let taskId = request.content.userInfo[idKey] as? String else {
                    return
                }
                if let task = DataManager.shared.getTask(taskId) {
                    let category = task.category
                    if !categoryList.contains(where: {$0 == category}) {
                        categoryList.append(category)
                        taskList[category] = [task]
                    } else {
                        taskList[category]?.append(task)
                    }
                } else {
                    DataManager.shared.deleteAlarmPush(taskId, request.identifier)
                }
            }
            labelNilMsg.isHidden = taskList.count == 0 ? false : true
            imgClock.isHidden = taskList.count == 0 ? false : true
            pushTable.reloadData()
            
            SystemManager.shared.closeLoading()
            if isRefresh {
                endAppearanceTransition()
                isRefresh = false
            }
        }
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
    func deletePush(_ indexPath:IndexPath) {
        let category = categoryList[indexPath.section]
        guard let task = taskList[category]?[indexPath.row] else {
            return
        }
        guard let option = task.optionData else {
            return
        }
        let newOption = OptionData(taskId: task.taskId, weekDay: task.getWeekDayList(), weekOfMonth: option.weekOfMonth, isEnd: option.isEnd, taskEndDate: option.taskEndDate, isAlarm: false, alarmTime: "")
        let newTask = EachTask(id: task.taskId, taskDay: task.taskDay, category: task.category, time: task.taskTime, title: task.title, memo: task.memo, repeatType: task.repeatType, optionData: newOption, isDone: task.isDone)
        // task data 업데이트
        DataManager.shared.updateTask(newTask)
        // 리스트 삭제
        taskList[category]?.remove(at: indexPath.row)
        if let list = taskList[category] {
            if list.isEmpty {
                categoryList.remove(at: indexPath.section)
            }
        }
        pushTable.reloadData()
    }
}

//MARK: - Button Event
extension PushListViewController {
    //SegmentedControl
    @IBAction func changeSegment(_ sender:UISegmentedControl) {
        if pushTable.isEditing {
            changeEditMode(false)
        }
        refresh()
    }
    private func refresh() {
        isRefresh = true
        beginAppearanceTransition(true, animated: true)
    }
    //
    @IBAction func clickEditMode(_ sender:Any) {
        if taskList.count == 0 {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "편집 가능한 알림이 없습니다")
            return
        }
        btnEdit.isSelected = !btnEdit.isSelected
        changeEditMode(btnEdit.isSelected)
    }
    private func changeEditMode(_ isOn:Bool) {
        pushTable.setEditing(isOn, animated: true)
        btnEdit.setImage(UIImage(systemName: isOn ? "rectangle.portrait.and.arrow.right" : "scissors", withConfiguration: mediumConfig), for: .normal)
        for cell in pushTable.visibleCells {
            cell.selectionStyle = isOn ? .default : .none
        }
        controllEditView(isOn)
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
        changeEditMode(false)
    }
}
