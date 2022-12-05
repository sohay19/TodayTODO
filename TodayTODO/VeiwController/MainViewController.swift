//
//  MainViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var imgNil: UIImageView!
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var underline: UIView!
    //
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnToday: UIButton!
    //
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelTodayNilMsg: UILabel!
    @IBOutlet weak var labelMonthNilMsg: UILabel!
    //
    @IBOutlet weak var dailyTaskTable: UITableView!
    @IBOutlet weak var monthlyTaskTable: UITableView!
    //
    @IBOutlet weak var calendarView: CustomCalendarView!
    @IBOutlet weak var todayView: UIView!
    @IBOutlet weak var monthView: UIView!
    
    var segmentControl = CustomSegmentControl()
    //
    var monthDate:Date = Date()
    //
    var categoryList:[String] = []
    var resultList:[String:[EachTask]] = [:]
    //key = 일자
    var monthlyTaskList:[Int:MonthltyDayTask] = [:]
    var taskDateKeyList:[Int] = []
    //
    var currentType:MainType = .Today
    var openedTask:OpenedTask?
    var isRefresh = false
    var isTaskOpen = false
    
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
        DataManager.shared.setReloadMain(refresh)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        checkVersion()
        //날짜가 넘어갔는지 확인
        guard let today = calendarView.today else {
            return
        }
        if today != Date() {
            calendarView.today = Date()
            calendarView.select(Date())
        }
        //
        loadTask()
        initSegment()
        initDate()
    }
    //버전체크
    private func checkVersion() {
        guard #available(iOS 15, *) else {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "iOS 15이상에서만 사용가능합니다.\n[설정->일반->소프트웨어 업데이트]\n에서 업데이트해주세요.", complete: { _ in
                SystemManager.shared.openSettingMenu()
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //
        openedTask = nil
        currentType = isTaskOpen ? currentType : .Today
        isTaskOpen = false
    }
}

//MARK: - UI
extension MainViewController {
    func initDate() {
        var dateList:[Substring] = []
        dateList = Utils.dateToDateString(currentType == .Today ? Date() : monthDate).split(separator: "-")
        switch currentType {
        case .Today:
            labelDate.text = "\(dateList[1])월\(dateList[2])일"
        case .Month:
            labelDate.text = "\(dateList[0])년 \(dateList[1])월"
        }
    }
    //
    func initUI() {
        // 배경 설정
        let backgroundView = UIImageView(frame: UIScreen.main.bounds)
        backgroundView.image = UIImage(named: BackgroundImage)
        view.insertSubview(backgroundView, at: 0)
        //
        segmentView.backgroundColor = .clear
        addSegmentcontrol()
        underline.backgroundColor = .label
        //
        todayView.backgroundColor = .clear
        monthView.backgroundColor = .clear
        // 폰트 설정
        labelDate.font = UIFont(name: N_Font, size: N_FontSize + 1.0)
        labelTodayNilMsg.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelMonthNilMsg.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelDate.textColor = .label
        labelTodayNilMsg.textColor = .label
        labelMonthNilMsg.textColor = .label
        //
        btnAdd.contentMode = .center
        btnAdd.setImage(UIImage(systemName: "scribble.variable", withConfiguration: mediumConfig), for: .normal)
        btnToday.contentMode = .center
        btnToday.setImage(UIImage(systemName: "plus.viewfinder", withConfiguration: mediumConfig), for: .normal)
        //
        dailyTaskTable.sectionHeaderTopPadding = 0
        dailyTaskTable.sectionHeaderHeight = 42
        dailyTaskTable.sectionFooterHeight = 45
        dailyTaskTable.backgroundColor = .clear
        dailyTaskTable.separatorInsetReference = .fromCellEdges
        dailyTaskTable.separatorColor = .lightGray.withAlphaComponent(0.5)
        dailyTaskTable.showsVerticalScrollIndicator = false
        //
        monthlyTaskTable.sectionHeaderTopPadding = 0
        monthlyTaskTable.sectionHeaderHeight = 42
        monthlyTaskTable.sectionFooterHeight = 45
        monthlyTaskTable.backgroundColor = .clear
        monthlyTaskTable.separatorInsetReference = .fromCellEdges
        monthlyTaskTable.separatorColor = .lightGray.withAlphaComponent(0.5)
        monthlyTaskTable.showsVerticalScrollIndicator = false
    }
    //
    private func addSegmentcontrol() {
        let segment = CustomSegmentControl(items: ["Today TODO", "Month TODO"])
        segment.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: segmentView.frame.size)
        segment.addTarget(self, action: #selector(changeSegment(_:)), for: .valueChanged)
        segment.selectedSegmentIndex = 0
        segmentControl = segment
        segmentView.addSubview(segment)
    }
    //
    func initCell() {
        let nibName = UINib(nibName: "TaskCell", bundle: nil)
        dailyTaskTable.register(nibName, forCellReuseIdentifier: "TaskCell")
        monthlyTaskTable.register(nibName, forCellReuseIdentifier: "TaskCell")
    }
    //
    func initSegment() {
        switch currentType {
        case .Today:
            segmentControl.selectedSegmentIndex = 0
            monthView.isHidden = true
            todayView.isHidden = false
            btnToday.isHidden = true
        case .Month:
            segmentControl.selectedSegmentIndex = 1
            monthView.isHidden = false
            todayView.isHidden = true
            btnToday.isHidden = false
            calendarView.select(monthDate)
        }
    }
    func refresh() {
        isRefresh = true
        beginAppearanceTransition(true, animated: false)
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
        resetTask()
        //
        switch currentType {
        case .Today:
            let dataList = DataManager.shared.getTodayTask()
            let sortedList = dataList.sorted(by: { task1, task2 in
                if task1.isDone {
                    return task2.isDone ? true : false
                } else {
                    return true
                }
            })
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
        case .Month:
            let dataList = DataManager.shared.getMonthTask(date: monthDate)
            let sortedList = dataList.sorted(by: { task1, task2 in
                if task1.isDone {
                    return task2.isDone ? true : false
                } else {
                    return true
                }
            })
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
        }
        sortCategory()
        calendarView.reloadData()
        reloadTable()
        //
        SystemManager.shared.closeLoading()
        if isRefresh {
            endAppearanceTransition()
            isRefresh = false
        }
    }
    //
    private func sortCategory() {
        let list = DataManager.shared.getCategoryOrder()
        switch currentType {
        case .Today:
            categoryList.sort {
                if let first = list.firstIndex(of: $0), let second = list.firstIndex(of: $1) {
                    return first < second
                }
                return false
            }
        case .Month:
            for day in taskDateKeyList {
                if let _ = monthlyTaskList[day] {
                    monthlyTaskList[day]?.sortCateogry(list)
                }
            }
        }
    }
    //
    func checkNil() {
        switch currentType {
        case .Today:
            if resultList.keys.count == 0 {
                labelTodayNilMsg.isHidden = false
                imgNil.isHidden = false
            } else {
                labelTodayNilMsg.isHidden = true
                imgNil.isHidden = true
            }
        case .Month:
            guard let list = monthlyTaskList[Utils.getDay(monthDate)] else {
                labelMonthNilMsg.isHidden = false
                return
            }
            if list.isEmpty {
                labelMonthNilMsg.isHidden = false
            } else {
                labelMonthNilMsg.isHidden = true
            }
        }
    }
    //
    func taskIsDone(_ isDone:Bool, _ indexPath:IndexPath) {
        switch currentType {
        case .Today:
            //Today
            let category = categoryList[indexPath.section]
            guard let task = resultList[category]?[indexPath.row] else {
                return
            }
            let modifyTask = task.clone()
            modifyTask.isDone = isDone
            DataManager.shared.updateTask(modifyTask)
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
        case .Month:
            //Month
            guard let category = monthlyTaskList[Utils.getDay(monthDate)]?.categoryList[indexPath.section] else {
                return
            }
            guard let task = monthlyTaskList[Utils.getDay(monthDate)]?.taskList[category]?[indexPath.row] else {
                return
            }
            let modifyTask = task.clone()
            modifyTask.isDone = isDone
            DataManager.shared.updateTask(modifyTask)
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
        }
    }
    //
    func modifyTask(_ indexPath:IndexPath) {
        var beforeTask:EachTask = EachTask()
        switch currentType {
        case .Today:
            let category = categoryList[indexPath.section]
            guard let task = resultList[category]?[indexPath.row] else {
                return
            }
            beforeTask = task
        case .Month:
            guard let category = monthlyTaskList[Utils.getDay(monthDate)]?.categoryList[indexPath.section] else {
                return
            }
            guard let task = monthlyTaskList[Utils.getDay(monthDate)]?.taskList[category]?[indexPath.row] else {
                return
            }
            beforeTask = task
        }
        SystemManager.shared.openTaskInfo(.MODIFY, date: nil, task: beforeTask, load: loadTask, modify: { newTask in
            DataManager.shared.updateTask(newTask)
        })
    }
    //
    func deleteTask(_ indexPath:IndexPath) {
        switch currentType {
        case .Today:
            let category = categoryList[indexPath.section]
            guard let task = resultList[category]?[indexPath.row] else {
                return
            }
            guard let type = RepeatType(rawValue: task.repeatType) else { return }
            if type != .None {
                var actionList:[(UIAlertAction)->Void] = []
                // 모두 삭제
                actionList.append { _ in
                    DataManager.shared.deleteTask(task)
                }
                // 이전 일정 유지
                actionList.append { _ in
                    let newTask = task.clone()
                    guard let date = Utils.beforeDay(Date()) else { return }
                    if Utils.dateToDateString(date) == task.taskDay {
                        newTask.stopRepeat()
                    } else {
                        newTask.optionData?.isEnd = true
                        newTask.optionData?.taskEndDate = Utils.dateToDateString(date)
                    }
                    // 종료일을 이전날까지로 변경하여 업데이트
                    DataManager.shared.updateTask(newTask)
                }
                // 취소
                actionList.append { _ in
                    ()
                }
                PopupManager.shared.openAlertSheet(self, title: "TODO 삭제", msg: "TODO를 삭제하시겠습니까?",
                                                   btnMsg: ["모두 삭제", "이전 TODO 유지", "취소"],
                                                   complete: actionList)
            } else {
                DataManager.shared.deleteTask(task)
            }
        case .Month:
            guard let category = monthlyTaskList[Utils.getDay(monthDate)]?.categoryList[indexPath.section] else {
                return
            }
            guard let task = monthlyTaskList[Utils.getDay(monthDate)]?.taskList[category]?[indexPath.row] else {
                return
            }
            guard let type = RepeatType(rawValue: task.repeatType) else { return }
            if type != .None {
                var actionList:[(UIAlertAction)->Void] = []
                // 모두 삭제
                actionList.append { _ in
                    DataManager.shared.deleteTask(task)
                }
                // 이전 일정 유지
                actionList.append { [self] _ in
                    let newTask = task.clone()
                    guard let date = Utils.beforeDay(monthDate) else { return }
                    if Utils.dateToDateString(date) == task.taskDay {
                        newTask.stopRepeat()
                    } else {
                        newTask.optionData?.isEnd = true
                        newTask.optionData?.taskEndDate = Utils.dateToDateString(date)
                    }
                    // 종료일을 이전날까지로 변경하여 업데이트
                    DataManager.shared.updateTask(newTask)
                }
                // 취소
                actionList.append { _ in
                    ()
                }
                PopupManager.shared.openAlertSheet(self, title: "TODO 삭제", msg: "TODO를 삭제하시겠습니까?",
                                                   btnMsg: ["모두 삭제", "이전 TODO 유지", "취소"],
                                                   complete: actionList)
            } else {
                DataManager.shared.deleteTask(task)
            }
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
            switch currentType {
            case .Today:
                dailyTaskTable.refreshControl?.endRefreshing()
                dailyTaskTable.reloadData()
            case .Month:
                monthlyTaskTable.refreshControl?.endRefreshing()
                monthlyTaskTable.reloadData()
            }
        }
    }
    //
    func reloadTable() {
        //스크롤 이동
        DispatchQueue.main.async { [self] in
            dailyTaskTable.setContentOffset(.zero, animated: true)
            monthlyTaskTable.setContentOffset(.zero, animated: true)
        }
        checkNil()
        switch currentType {
        case .Today:
            dailyTaskTable.reloadData()
        case .Month:
            monthlyTaskTable.reloadData()
        }
    }
}

//MARK: - Button Event
extension MainViewController {
    //SegmentedControl
    @objc private func changeSegment(_ sender:UISegmentedControl) {
        //
        switch segmentControl.selectedSegmentIndex {
        case 0:
            currentType = .Today
            btnToday.isHidden = true
        case 1:
            currentType = .Month
            openedTask = nil
            btnToday.isHidden = false
        default:
            return
        }
        refresh()
    }
    @IBAction func clickTaskAdd(_ sender:Any) {
        let date = currentType == .Today ? Date() : monthDate
        isTaskOpen = true
        SystemManager.shared.openTaskInfo(.ADD, date: date, task: nil, load:loadTask, modify: nil)
    }
    @IBAction func clickToday(_ sender:Any) {
        monthDate = Date()
        calendarView.select(monthDate)
        reloadTable()
    }
}

