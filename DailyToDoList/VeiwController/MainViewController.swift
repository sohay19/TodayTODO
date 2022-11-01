//
//  MainViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelTodayNilMsg: UILabel!
    @IBOutlet weak var labelMonthNilMsg: UILabel!
    //
    @IBOutlet weak var dailyTaskTable: UITableView!
    @IBOutlet weak var monthlyTaskTable: UITableView!
    //
    @IBOutlet weak var segmentedController: UISegmentedControl!
    //
    @IBOutlet weak var calendarView: CustomCalendarView!
    @IBOutlet weak var todayView: UIView!
    @IBOutlet weak var monthView: UIView!
    //
    @IBOutlet weak var btnEdit: UIButton!
    
    //
    var currentDate:Date = Date()
    var beforeDate:Date = Date()
    //
    var taskList:[EachTask] = []
    var monthlyTaskList:[Int:[EachTask]] = [:]
    var taskDateKeyList:[Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.navigationItem.setHidesBackButton(true, animated: false)
        //
        dailyTaskTable.dataSource = self
        dailyTaskTable.delegate = self
        //
        monthlyTaskTable.dataSource = self
        monthlyTaskTable.delegate = self
        //
        calendarView.dataSource = self
        calendarView.delegate = self
        //
        initRefreshController()
        //
        RealmManager.shared.reloadMainView = viewWillAppear(_:)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        //버전체크
        guard #available(iOS 15, *) else {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "iOS 15이상에서만 사용가능합니다.\n[설정->일반->소프트웨어 업데이트]\n에서 업데이트해주세요.", complete: { _ in
                SystemManager.shared.openSettingMenu()
            })
        }
        DispatchQueue.main.async { [self] in
            //
            loadTask()
            //
            initDate()
            initUI()
            //
            changeSegment()
        }
    }
}

//MARK: - UI
extension MainViewController {
    func initDate() {
        let date = Utils.dateToDateString(Date())
        labelDate.text = date
    }
    
    func initUI() {
        monthView.isHidden = true
    }
    
    func changeSegment() {
        switch segmentedController.selectedSegmentIndex {
        case 0:
            beforeDate = currentDate
            currentDate = Date()
            //Today
            monthView.isHidden = true
            todayView.isHidden = false
        case 1:
            currentDate = beforeDate
            //Month
            monthView.isHidden = false
            todayView.isHidden = true
        default:
            break
        }
    }
}

//MARK: - Task
extension MainViewController {
    //Task 세팅
    func loadTask() {
        switch segmentedController.selectedSegmentIndex {
        case 0:
            // data reset
            taskList = []
            monthlyTaskList = [:]
            taskDateKeyList = []
            let dataList = RealmManager.shared.getTaskDataForDay(date: currentDate)
            taskList = dataList.sorted(by: { task1, task2 in
                if task1.isDone {
                    return task2.isDone ? true : false
                } else {
                    return true
                }
            })
            //
            if taskList.count == 0 {
                labelTodayNilMsg.isHidden = false
            } else {
                labelTodayNilMsg.isHidden = true
            }
            //
            dailyTaskTable.reloadData()
            dailyTaskTable.flashScrollIndicators()
        case 1:
            // data reset
            taskList = []
            monthlyTaskList = [:]
            taskDateKeyList = []
            //
            let dataList = RealmManager.shared.getTaskDataForMonth(date: currentDate)
            //한달
            taskDateKeyList = [Int](1...Utils.getLastDay(currentDate))
            //딕셔너리 초기화
            for i in taskDateKeyList {
                monthlyTaskList[i] = []
            }
            //
            let tmpList = dataList.map{$0}
            let weekDayList = Utils.getWeekDayList(currentDate)
            //
            let curMonthDays = Utils.dateToDateString(currentDate).split(separator: "-").map{String($0)}
            //반복 타입 별 체크
            for task in tmpList {
                switch RepeatType(rawValue: task.repeatType) {
                case .None:
                    let day = Utils.getDay(task.taskDay)
                    monthlyTaskList[day]?.append(task)
                case .EveryDay:
                    for day in taskDateKeyList {
                        var compareDay = curMonthDays
                        compareDay[2] = String(format: "%02d", day)
                        if task.taskDay <= compareDay.joined(separator: "-") {
                            monthlyTaskList[day]?.append(task)
                        }
                    }
                case .Eachweek:
                    for weekDay in task.getWeekDays() {
                        guard let weekDayList = weekDayList[weekDay] else {
                            return
                        }
                        for day in weekDayList {
                            var compareDay = curMonthDays
                            compareDay[2] = String(format: "%02d", day)
                            if task.taskDay <= compareDay.joined(separator: "-") {
                                monthlyTaskList[day]?.append(task)
                            }
                        }
                    }
                case .EachWeekOfMonth:
                    let daysList = Utils.findDay(currentDate, task.weekOfMonth, task.getWeekDays())
                    for day in daysList {
                        var compareDay = curMonthDays
                        compareDay[2] = String(format: "%02d", day)
                        if task.taskDay <= compareDay.joined(separator: "-") {
                            monthlyTaskList[day]?.append(task)
                        }
                    }
                default:
                    //EachMonthOfOnce
                    //EachYear
                    for day in taskDateKeyList {
                        var compareDay = curMonthDays
                        compareDay[2] = String(format: "%02d", day)
                        if task.taskDay <= compareDay.joined(separator: "-") && day == Utils.getDay(task.taskDay) {
                            monthlyTaskList[day]?.append(task)
                        }
                    }
                }
            }
            //month가 바뀌었으므로 캘린더 리로드
            calendarView.reloadData()
            //
            changeDay()
        default:
            break
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            SystemManager.shared.closeLoading()
        }
    }
    // 선택된 날짜에 맞는 테이블 로드
    func changeDay() {
        //
        guard let day = Calendar.current.dateComponents([.day], from: currentDate).day else {
            return
        }
        //
        if let monthlyTaskList = monthlyTaskList[day] {
            labelMonthNilMsg.isHidden = true
            taskList = monthlyTaskList.sorted(by: { task1, task2 in
                if task1.isDone {
                    return task2.isDone ? true : false
                } else {
                    return true
                }
            })
        } else {
            labelMonthNilMsg.isHidden = false
            taskList = []
        }
        //
        monthlyTaskTable.reloadData()
        monthlyTaskTable.flashScrollIndicators()
    }
    //
    func taskIsDone(_ isDone:Bool, _ indexPath:IndexPath) {
        let modifyTask = taskList[indexPath.row].clone()
        modifyTask.isDone = isDone
        RealmManager.shared.updateTaskDataForiOS(modifyTask)
        switch segmentedController.selectedSegmentIndex {
        case 0:
            //Today
            dailyTaskTable.reloadRows(at: [indexPath], with: .none)
            let task = taskList.remove(at: indexPath.row)
            if isDone {
                taskList.append(task)
            } else {
                taskList = [task] + taskList
            }
            dailyTaskTable.reloadData()
        case 1:
            //Month
            monthlyTaskTable.reloadRows(at: [indexPath], with: .none)
            let task = taskList.remove(at: indexPath.row)
            if isDone {
                taskList.append(task)
            } else {
                taskList = [task] + taskList
            }
            monthlyTaskTable.reloadData()
        default:
            break
        }
    }
    //
    func modifyTask(_ task:EachTask, _ indexPath:IndexPath) {
        RealmManager.shared.updateTaskDataForiOS(task)
        taskList[indexPath.row] = task
        //
        switch segmentedController.selectedSegmentIndex {
        case 0:
            //Today
            dailyTaskTable.reloadRows(at: [indexPath], with: .none)
        case 1:
            //Month
            monthlyTaskTable.reloadRows(at: [indexPath], with: .none)
        default:
            break
        }
    }
    //
    func deleteTask(_ indexPath:IndexPath) {
        let task = taskList[indexPath.row]
        RealmManager.shared.deleteTaskDataForiOS(task)
        taskList.remove(at: indexPath.row)
        //
        switch segmentedController.selectedSegmentIndex {
        case 0:
            dailyTaskTable.deleteRows(at: [indexPath], with: .none)
        case 1:
            monthlyTaskTable.deleteRows(at: [indexPath], with: .none)
        default:
            break
        }
    }
}

//MARK: - initialize, refresh
extension MainViewController {
    //refresh controller 초기세팅
    func initRefreshController() {
        //Today
        let todayRefreshControl = UIRefreshControl()
        todayRefreshControl.addTarget(self, action: #selector(refreshTaskView), for: .valueChanged)
        //초기화
        todayRefreshControl.endRefreshing()
        dailyTaskTable.refreshControl = todayRefreshControl
        //Month
        let monthRefreshControl = UIRefreshControl()
        monthRefreshControl.addTarget(self, action: #selector(refreshTaskView), for: .valueChanged)
        //초기화
        monthRefreshControl.endRefreshing()
        monthlyTaskTable.refreshControl = monthRefreshControl
    }
    //
    @objc func refreshTaskView() {
        switch segmentedController.selectedSegmentIndex {
        case 0:
            dailyTaskTable.refreshControl?.endRefreshing()
            dailyTaskTable.reloadData()
        case 1:
            monthlyTaskTable.refreshControl?.endRefreshing()
            monthlyTaskTable.reloadData()
        default:
            break
        }
    }
}

//MARK: - Button Event
extension MainViewController {
    @IBAction func clickTaskAdd(_ sender:Any) {//
        if dailyTaskTable.isEditing {
            changeEditMode()
            return
        }
        let board = UIStoryboard(name: taskInfoBoard, bundle: nil)
        guard let nextVC = board.instantiateViewController(withIdentifier: taskInfoBoard) as? TaskInfoViewController else { return }
        //
        nextVC.currentMode = .ADD
        nextVC.refreshTask = loadTask
        //
        nextVC.currntDate = currentDate
        nextVC.modalTransitionStyle = .crossDissolve
        nextVC.modalPresentationStyle = .overCurrentContext
        
        present(nextVC, animated: true)
    }
    //
    @IBAction func changeDailyTaskEditMode(_ sender:UIButton) {
        changeEditMode()
    }
    private func changeEditMode() {
        if dailyTaskTable.isEditing {
            btnEdit.setTitle("Edit", for: .normal)
            dailyTaskTable.setEditing(false, animated: false)
        } else {
            btnEdit.setTitle("Done", for: .normal)
            dailyTaskTable.setEditing(true, animated: false)
        }
    }
    //
    @IBAction func deleteAllNoti(_ sender:Any) {
        //
        if dailyTaskTable.isEditing {
            changeEditMode()
            return
        }
        PushManager.shared.deleteAllPush()
        RealmManager.shared.deleteAllAlarm()
    }
    //SegmentedControl
    @IBAction func changeSegment(_ sender:UISegmentedControl) {//
        if dailyTaskTable.isEditing {
            changeEditMode()
            return
        }
        currentDate = Date()
        calendarView.select(currentDate)
        //
        SystemManager.shared.openLoading()
        //
        viewWillAppear(true)
    }
    //SideMenu
    @IBAction func clickSideMenu(_ sender:Any) {//
        if dailyTaskTable.isEditing {
            changeEditMode()
            return
        }
        SystemManager.shared.openSideMenu(self)
    }
}

