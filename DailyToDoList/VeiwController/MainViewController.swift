//
//  MainViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var imgUnderline: UIImageView!
    //
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelTodayNilMsg: UILabel!
    @IBOutlet weak var labelMonthNilMsg: UILabel!
    //
    @IBOutlet weak var dailyTaskTable: UITableView!
    @IBOutlet weak var monthlyTaskTable: UITableView!
    //
    @IBOutlet weak var segmentedController: CustomSegmentControl!
    @IBOutlet weak var btnAdd: UIButton!
    //
    @IBOutlet weak var calendarView: CustomCalendarView!
    @IBOutlet weak var todayView: UIView!
    @IBOutlet weak var monthView: UIView!
    
    //
    var todayDate:Date = Date()
    var monthDate:Date = Date()
    //
    var categoryList:[String] = []
    var resultList:[String:[EachTask]] = [:]
    //key = 일자
    var monthlyTaskList:[Int:MonthltyDayTask] = [:]
    var taskDateKeyList:[Int] = []
    //
    var openedTask:OpenedTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        dailyTaskTable.dataSource = self
        dailyTaskTable.delegate = self
        monthlyTaskTable.dataSource = self
        monthlyTaskTable.delegate = self
        calendarView.dataSource = self
        calendarView.delegate = self
        //
        initUI()
        initCell()
        // 리프레시 컨트롤러 초기화
        initRefreshController()
        // 메인 리로드 함수
        RealmManager.shared.reloadMainView = refresh
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        checkVersion()
        loadTask()
        DispatchQueue.main.async { [self] in
            initDate()
            initSegment()
        }
    }
    
    //버전체크
    private func checkVersion() {
        guard #available(iOS 15, *) else {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "iOS 15이상에서만 사용가능합니다.\n[설정->일반->소프트웨어 업데이트]\n에서 업데이트해주세요.", complete: { _ in
                SystemManager.shared.openSettingMenu()
            })
        }
    }
}

//MARK: - UI
extension MainViewController {
    func initDate() {
        var date:[Substring] = []
        switch segmentedController.selectedSegmentIndex {
        case 0:
            date = Utils.dateToDateString(todayDate).split(separator: "-")
        case 1:
            date = Utils.dateToDateString(monthDate).split(separator: "-")
            date.removeLast()
        default:
            return
        }
        labelDate.text = date.joined(separator: ". ")
    }
    //
    func initUI() {
        // 배경 설정
        let backgroundView = UIImageView(frame: UIScreen.main.bounds)
        backgroundView.image = UIImage(named: BackgroundImage)
        view.insertSubview(backgroundView, at: 0)
        //
        todayView.backgroundColor = .clear
        monthView.backgroundColor = .clear
        // 폰트 설정
        btnAdd.contentMode = .center
        btnAdd.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: mediumConfig), for: .normal)
        labelDate.font = UIFont(name: E_N_Font_E, size: MenuFontSize)
        labelTodayNilMsg.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelMonthNilMsg.font = UIFont(name: K_Font_R, size: K_FontSize)
        //
        dailyTaskTable.sectionHeaderTopPadding = 18
        dailyTaskTable.backgroundColor = .clear
        dailyTaskTable.separatorInsetReference = .fromCellEdges
        dailyTaskTable.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        dailyTaskTable.separatorColor = .label
        dailyTaskTable.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //
        monthlyTaskTable.sectionHeaderTopPadding = 18
        monthlyTaskTable.backgroundColor = .clear
        monthlyTaskTable.separatorInsetReference = .fromCellEdges
        monthlyTaskTable.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        monthlyTaskTable.separatorColor = .label
        monthlyTaskTable.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //
        monthView.isHidden = true
    }
    //
    func initCell() {
        let nibName = UINib(nibName: "TaskCell", bundle: nil)
        dailyTaskTable.register(nibName, forCellReuseIdentifier: "TaskCell")
        monthlyTaskTable.register(nibName, forCellReuseIdentifier: "TaskCell")
    }
    //
    func initSegment() {
        //
        imgUnderline.image = UIImage(named: segmentedController.selectedSegmentIndex == 0 ? Underline_Pink : Underline_Indigo)
        imgUnderline.alpha = 0.3
        //
        switch segmentedController.selectedSegmentIndex {
        case 0:
            //Today
            monthView.isHidden = true
            todayView.isHidden = false
        case 1:
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
    // data reset
    func resetTask() {
        taskDateKeyList = []
        categoryList = []
        resultList = [:]
        monthlyTaskList = [:]
    }
    //Task 세팅
    func loadTask() {
        DispatchQueue.main.async { [self] in
            resetTask()
            switch segmentedController.selectedSegmentIndex {
            case 0:
                let dataList = RealmManager.shared.getTaskDataForDay(date: todayDate)
                let sortedList = dataList.sorted(by: { task1, task2 in
                    if task1.isDone {
                        return task2.isDone ? true : false
                    } else {
                        return true
                    }
                })
                //
                for task in sortedList {
                    let category = task.category
                    if !categoryList.contains(where: {$0 == category}) {
                        categoryList.append(category)
                        resultList[category] = []
                    }
                    if resultList[category] != nil {
                        resultList[category]?.append(task)
                    }
                }
            case 1:
                let dataList = RealmManager.shared.getTaskDataForMonth(date: monthDate)
                let sortedList = dataList.sorted(by: { task1, task2 in
                    if task1.isDone {
                        return task2.isDone ? true : false
                    } else {
                        return true
                    }
                })
                //
                for task in sortedList {
                    let category = task.category
                    if !categoryList.contains(where: {$0 == category}) {
                        categoryList.append(category)
                        resultList[category] = []
                    }
                    if resultList[category] != nil {
                        resultList[category]?.append(task)
                    }
                }
                //한달
                taskDateKeyList = [Int](1...Utils.getLastDay(monthDate))
                //딕셔너리 초기화
                for i in taskDateKeyList {
                    monthlyTaskList[i] = MonthltyDayTask()
                }
                //
                let weekDayList = Utils.getWeekDayList(monthDate)
                var compareDay = Utils.dateToDateString(monthDate).split(separator: "-").map{String($0)}
                //반복 타입 별 체크
                for task in sortedList {
                    let option = task.optionData ?? OptionData()
                    let isEnd = option.isEnd
                    let taskEndDate = option.taskEndDate
                    //
                    switch RepeatType(rawValue: task.repeatType) {
                    case .None:
                        let day = Utils.getDay(task.taskDay)
                        monthlyTaskList[day]?.append(task.category, task)
                    case .EveryDay:
                        for day in taskDateKeyList {
                            compareDay[2] = String(format: "%02d", day)
                            let currentDay = compareDay.joined(separator: "-")
                            if isEnd {
                                if taskEndDate >= currentDay && task.taskDay <= currentDay {
                                    monthlyTaskList[day]?.append(task.category, task)
                                }
                            } else {
                                if task.taskDay <= currentDay {
                                    monthlyTaskList[day]?.append(task.category, task)
                                }
                            }
                        }
                    case .Eachweek:
                        for weekDay in task.getWeekDays() {
                            guard let weekDayList = weekDayList[weekDay] else {
                                return
                            }
                            for day in weekDayList {
                                compareDay[2] = String(format: "%02d", day)
                                let currentDay = compareDay.joined(separator: "-")
                                if isEnd {
                                    if taskEndDate >= currentDay && task.taskDay <= currentDay {
                                        monthlyTaskList[day]?.append(task.category, task)
                                    }
                                } else {
                                    if task.taskDay <= currentDay {
                                        monthlyTaskList[day]?.append(task.category, task)
                                    }
                                }
                            }
                        }
                    case .EachWeekOfMonth:
                        let daysList = Utils.findDay(monthDate, option.weekOfMonth, task.getWeekDays())
                        for day in daysList {
                            compareDay[2] = String(format: "%02d", day)
                            let currentDay = compareDay.joined(separator: "-")
                            if isEnd {
                                if taskEndDate >= currentDay && task.taskDay <= currentDay {
                                    monthlyTaskList[day]?.append(task.category, task)
                                }
                            } else {
                                if task.taskDay <= currentDay {
                                    monthlyTaskList[day]?.append(task.category, task)
                                }
                            }
                        }
                    default:
                        //EachMonthOfOnce
                        //EachYear
                        for day in taskDateKeyList {
                            compareDay[2] = String(format: "%02d", day)
                            let currentDay = compareDay.joined(separator: "-")
                            
                            if isEnd {
                                if taskEndDate >= currentDay && task.taskDay <= currentDay && day == Utils.getDay(task.taskDay) {
                                    monthlyTaskList[day]?.append(task.category, task)
                                }
                            } else {
                                if task.taskDay <= currentDay && day == Utils.getDay(task.taskDay) {
                                    monthlyTaskList[day]?.append(task.category, task)
                                }
                            }
                            
                        }
                    }
                }
                //month가 바뀌었으므로 캘린더 리로드
                calendarView.reloadData()
            default:
                break
            }
            reloadTable()
            SystemManager.shared.closeLoading()
            endAppearanceTransition()
        }
    }
    //
    func checkNil() {
        switch segmentedController.selectedSegmentIndex {
        case 0:
            if resultList.keys.count == 0 {
                labelTodayNilMsg.isHidden = false
            } else {
                labelTodayNilMsg.isHidden = true
            }
        case 1:
            guard let list = monthlyTaskList[Utils.getDay(monthDate)] else {
                labelMonthNilMsg.isHidden = false
                return
            }
            if list.isEmpty {
                labelMonthNilMsg.isHidden = false
            } else {
                labelMonthNilMsg.isHidden = true
            }
        default:
            return
        }
    }
    //
    func taskIsDone(_ isDone:Bool, _ indexPath:IndexPath) {
        let category = categoryList[indexPath.section]
        switch segmentedController.selectedSegmentIndex {
        case 0:
            //Today
            guard let task = resultList[category]?[indexPath.row] else {
                return
            }
            let modifyTask = task.clone()
            modifyTask.isDone = isDone
            RealmManager.shared.updateTaskDataForiOS(modifyTask)
            //
            resultList[category]?.remove(at: indexPath.row)
            guard let taskList = resultList[category] else {
                return
            }
            if isDone {
                resultList[category]?.append(task)
            } else {
                resultList[category] = [task] + taskList
            }
            dailyTaskTable.reloadData()
        case 1:
            //Month
            guard let task = monthlyTaskList[Utils.getDay(monthDate)]?.taskList[category]?[indexPath.row] else {
                return
            }
            let modifyTask = task.clone()
            modifyTask.isDone = isDone
            RealmManager.shared.updateTaskDataForiOS(modifyTask)
            //
            let day = Utils.getDay(monthDate)
            monthlyTaskList[day]?.taskList[category]?.remove(at: indexPath.row)
            guard let taskList = monthlyTaskList[day]?.taskList[category] else {
                return
            }
            if isDone {
                monthlyTaskList[day]?.taskList[category]?.append(task)
            } else {
                monthlyTaskList[day]?.taskList[category] = [task] + taskList
            }
            monthlyTaskTable.reloadData()
        default:
            break
        }
    }
    //
    func modifyTask(_ indexPath:IndexPath) {
        let category = categoryList[indexPath.section]
        var beforeTask:EachTask = EachTask()
        switch segmentedController.selectedSegmentIndex {
        case 0:
            //Today
            guard let task = resultList[category]?[indexPath.row] else {
                return
            }
            beforeTask = task
            dailyTaskTable.reloadRows(at: [indexPath], with: .none)
        case 1:
            //Month
            guard let task = monthlyTaskList[Utils.getDay(monthDate)]?.taskList[category]?[indexPath.row] else {
                return
            }
            beforeTask = task
            monthlyTaskTable.reloadRows(at: [indexPath], with: .none)
        default:
            break
        }
        SystemManager.shared.openTaskInfo(.MODIFY, date: nil, task: beforeTask, load: loadTask, modify: afterModifyTask)
    }
    //
    func afterModifyTask(_ task:EachTask) {
        RealmManager.shared.updateTaskDataForiOS(task)
        //
        switch segmentedController.selectedSegmentIndex {
        case 0:
            //Today
            dailyTaskTable.reloadData()
        case 1:
            //Month
            monthlyTaskTable.reloadData()
        default:
            break
        }
    }
    //
    func deleteTask(_ indexPath:IndexPath) {
        let category = categoryList[indexPath.section]
        guard let task = resultList[category]?[indexPath.row] else {
            return
        }
        RealmManager.shared.deleteTaskDataForiOS(task)
        resultList[category]?.remove(at: indexPath.row)
        //
        switch segmentedController.selectedSegmentIndex {
        case 0:
            dailyTaskTable.deleteRows(at: [indexPath], with: .none)
            checkNil()
        case 1:
            SystemManager.shared.openLoading()
            loadTask()
        default:
            break
        }
    }
}

//MARK: - func
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
        DispatchQueue.main.async { [self] in
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
    //
    func reloadTable() {
        checkNil()
        switch segmentedController.selectedSegmentIndex {
        case 0:
            dailyTaskTable.reloadData()
        case 1:
            monthlyTaskTable.reloadData()
        default:
            return
        }
    }
}

//MARK: - Button Event
extension MainViewController {
    @IBAction func clickTaskAdd(_ sender:Any) {
        let date = segmentedController.selectedSegmentIndex == 0 ? todayDate : monthDate
        SystemManager.shared.openTaskInfo(.ADD, date: date, task: nil, load:loadTask, modify: nil)
    }
    //SegmentedControl
    @IBAction func changeSegment(_ sender:UISegmentedControl) {
        //
        switch segmentedController.selectedSegmentIndex {
        case 0:
            todayDate = Date()
        case 1:
            calendarView.select(monthDate)
        default:
            return
        }
        refresh()
    }
    private func refresh() {
        beginAppearanceTransition(true, animated: true)
    }
}

