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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //
        segmentControl.selectedSegmentIndex = 0
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
        labelTodayNilMsg.font = UIFont(name: K_Font_R, size: K_FontSize + 3.0)
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
        dailyTaskTable.sectionHeaderHeight = 30
        dailyTaskTable.sectionFooterHeight = 30
        dailyTaskTable.backgroundColor = .clear
        dailyTaskTable.separatorInsetReference = .fromCellEdges
        dailyTaskTable.separatorColor = .label
        dailyTaskTable.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //
        monthlyTaskTable.sectionHeaderTopPadding = 0
        monthlyTaskTable.sectionHeaderHeight = 30
        monthlyTaskTable.sectionFooterHeight = 30
        monthlyTaskTable.backgroundColor = .clear
        monthlyTaskTable.separatorInsetReference = .fromCellEdges
        monthlyTaskTable.separatorColor = .label
        monthlyTaskTable.scrollIndicatorInsets = UIEdgeInsets(top: 0, left:0, bottom: 0, right: 0)
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
            monthView.isHidden = true
            todayView.isHidden = false
            btnToday.isHidden = true
        case .Month:
            monthView.isHidden = false
            todayView.isHidden = true
            btnToday.isHidden = false
        }
    }
    private func refresh() {
        isRefresh = true
        beginAppearanceTransition(true, animated: true)
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
                //month가 바뀌었으므로 캘린더 리로드
                calendarView.reloadData()
            }
            //
            sortCategory()
            reloadTable()
            //
            SystemManager.shared.closeLoading()
            if isRefresh {
                endAppearanceTransition()
                isRefresh = false
            }
        }
    }
    //
    private func sortCategory() {
        guard let list = UserDefaults.shared.array(forKey: CategoryList) as? [String] else {
            return
        }
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
        let category = categoryList[indexPath.section]
        switch currentType {
        case .Today:
            //Today
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
        let category = categoryList[indexPath.section]
        var beforeTask:EachTask = EachTask()
        switch currentType {
        case .Today:
            guard let task = resultList[category]?[indexPath.row] else {
                return
            }
            beforeTask = task
        case .Month:
            guard let task = monthlyTaskList[Utils.getDay(monthDate)]?.taskList[category]?[indexPath.row] else {
                return
            }
            beforeTask = task
        }
        SystemManager.shared.openTaskInfo(.MODIFY, date: nil, task: beforeTask, load: loadTask, modify: afterModifyTask)
    }
    //
    func afterModifyTask(_ task:EachTask) {
        DataManager.shared.updateTask(task)
        //
        switch currentType {
        case .Today:
            dailyTaskTable.reloadData()
        case .Month:
            monthlyTaskTable.reloadData()
        }
    }
    //
    func deleteTask(_ indexPath:IndexPath) {
        let category = categoryList[indexPath.section]
        guard let task = resultList[category]?[indexPath.row] else {
            return
        }
        DataManager.shared.deleteTask(task)
        switch currentType {
        case .Today:
            resultList[category]?.remove(at: indexPath.row)
            if let list = resultList[category] {
                if list.isEmpty {
                    categoryList.remove(at: indexPath.section)
                }
            }
            dailyTaskTable.reloadData()
            checkNil()
        case .Month:
            SystemManager.shared.openLoading()
            loadTask()
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
            calendarView.select(monthDate)
            btnToday.isHidden = false
        default:
            return
        }
        refresh()
    }
    @IBAction func clickTaskAdd(_ sender:Any) {
        let date = currentType == .Today ? Date() : monthDate
        SystemManager.shared.openTaskInfo(.ADD, date: date, task: nil, load:loadTask, modify: nil)
    }
    @IBAction func clickToday(_ sender:Any) {
        monthDate = Date()
        calendarView.select(monthDate)
    }
}

