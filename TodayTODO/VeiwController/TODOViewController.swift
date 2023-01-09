//
//  MainViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit

class TODOViewController: UIViewController {
    @IBOutlet weak var imgNil: UIImageView!
    @IBOutlet weak var segmentView: UIView!
    //
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnToday: UIButton!
    @IBOutlet weak var btnSort: UIButton!
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
    var taskList:[EachTask] = []
    //key = 일자
    var monthlyTaskList:[Int:[EachTask]] = [:]
    var taskDateKeyList:[Int] = []
    //
    var currentType:MainType = .Today
    var sortType:SortType = .Category
    var isRefresh = false
    var isTaskOpen = false
    var isMoveToday = false
    //
    let backgroundView = UIImageView(frame: UIScreen.main.bounds)
    
    
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
        view.insertSubview(backgroundView, at: 0)
        addSegmentcontrol()
        initCell()
        initRefreshController()
        // 메인 리로드 함수
        WatchConnectManager.shared.reloadMainView = refresh
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        SystemManager.shared.openHelp(self, TODOBoard)
        //
        checkVersion()
        //날짜가 넘어갔는지 확인
        guard let today = calendarView.today else {
            return
        }
        if Utils.dateToDateString(today) != Utils.dateToDateString(Date()) {
            calendarView.today = Date()
            calendarView.select(Date())
        }
        //
        if let type = UserDefaults.shared.string(forKey: SortTypeKey) {
            if let newType = SortType(rawValue: type) {
                sortType = newType
            }
        }
        //
        initUI()
        loadTask()
        loadSort()
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
        currentType = isTaskOpen ? currentType : .Today
        isTaskOpen = false
    }
}

//MARK: - UI
extension TODOViewController {
    func initDate() {
        var dateList:[Substring] = []
        dateList = Utils.dateToDateString(currentType == .Today ? Date() : monthDate).split(separator: "-")
        var date = ""
        switch currentType {
        case .Today:
            date = "\(dateList[1])월 \(dateList[2])일"
        case .Month:
            date = "\(dateList[0])년 \(dateList[1])월"
        }
        labelDate.text = date
    }
    //
    func initUI() {
        // 배경 설정
        backgroundView.image = UIImage(named: BackgroundImage)
        //
        segmentView.backgroundColor = .clear
        // 폰트 설정
        labelDate.font = UIFont(name: LogoFont, size: 18.0)
        labelDate.textColor = .label
        labelTodayNilMsg.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelTodayNilMsg.textColor = .label
        labelMonthNilMsg.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelMonthNilMsg.textColor = .label
        //
        btnSort.titleLabel?.font = UIFont(name: K_Font_R, size: K_FontSize - 2.0)
        btnSort.setTitleColor(.label, for: .normal)
        //
        todayView.backgroundColor = .clear
        monthView.backgroundColor = .clear
        btnSort.setImage(UIImage(systemName: "chevron.down", withConfiguration: thinConfig), for: .normal)
        btnSort.contentMode = .center
        btnSort.tintColor = .label
        btnAdd.contentMode = .center
        btnAdd.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: mediumConfig), for: .normal)
        btnToday.contentMode = .center
        btnToday.setImage(UIImage(systemName: "plus.viewfinder", withConfiguration: mediumConfig), for: .normal)
        //
        dailyTaskTable.sectionHeaderHeight = 0
        dailyTaskTable.sectionFooterHeight = 0
        dailyTaskTable.backgroundColor = .clear
        dailyTaskTable.separatorInsetReference = .fromCellEdges
        dailyTaskTable.separatorColor = .lightGray.withAlphaComponent(0.5)
        dailyTaskTable.showsVerticalScrollIndicator = false
        //
        monthlyTaskTable.sectionHeaderHeight = 0
        monthlyTaskTable.sectionFooterHeight = 0
        monthlyTaskTable.backgroundColor = .clear
        monthlyTaskTable.separatorInsetReference = .fromCellEdges
        monthlyTaskTable.separatorColor = .lightGray.withAlphaComponent(0.5)
        monthlyTaskTable.showsVerticalScrollIndicator = false
        //
        imgNil.image = UIImage(named: DataManager.shared.getTheme() == BlackBackImage ? "pencil_white" : "pencil_black")
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
    //
    func loadSort() {
        var actionList:[UIAction] = []
        let sortList:[SortType] = [.Category, .Time]
        for type in sortList {
            let action = UIAction(title: type.rawValue, handler: { [self] _ in
                sortType = type
                btnSort.setTitle("\(sortType.rawValue) ", for: .normal)
                UserDefaults.shared.set(sortType.rawValue, forKey: SortTypeKey)
                sortTask()
            })
            actionList.append(action)
        }
        btnSort.menu = UIMenu(title: "정렬 기준", children: actionList)
        // 정렬
        if let index = sortList.firstIndex(where: {$0 == sortType}) {
            btnSort.sendAction(actionList[index])
        }
    }
    //
    func refresh() {
        isRefresh = true
        beginAppearanceTransition(true, animated: false)
    }
}

//MARK: - Task
extension TODOViewController {
    // data reset
    func resetTask() {
        taskDateKeyList = []
        taskList = []
        monthlyTaskList = [:]
    }
    //Task 세팅
    func loadTask() {
        resetTask()
        //
        switch currentType {
        case .Today:
            taskList = DataManager.shared.getTodayTask()
        case .Month:
            let dataList = DataManager.shared.getMonthTask(date: monthDate)
            //한달
            taskDateKeyList = [Int](1...Utils.getLastDay(monthDate))
            //딕셔너리 초기화
            for i in taskDateKeyList {
                monthlyTaskList[i] = [EachTask]()
            }
            //
            let weekDayList = Utils.getWeekDayList(monthDate)
            var compareDay = Utils.dateToDateString(monthDate).split(separator: "-").map{String($0)}
            //반복 타입 별 체크
            for task in dataList {
                let option = task.optionData ?? OptionData()
                let isEnd = option.isEnd
                let taskEndDate = option.taskEndDate
                //
                switch RepeatType(rawValue: task.repeatType) {
                case .None:
                    let day = Utils.getDay(task.taskDay)
                    monthlyTaskList[day]?.append(task)
                case .EveryDay:
                    for day in taskDateKeyList {
                        compareDay[2] = String(format: "%02d", day)
                        let currentDay = compareDay.joined(separator: "-")
                        if isEnd {
                            if taskEndDate >= currentDay && task.taskDay <= currentDay {
                                monthlyTaskList[day]?.append(task)
                            }
                        } else {
                            if task.taskDay <= currentDay {
                                monthlyTaskList[day]?.append(task)
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
                                    monthlyTaskList[day]?.append(task)
                                }
                            } else {
                                if task.taskDay <= currentDay {
                                    monthlyTaskList[day]?.append(task)
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
                                monthlyTaskList[day]?.append(task)
                            }
                        } else {
                            if task.taskDay <= currentDay {
                                monthlyTaskList[day]?.append(task)
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
                                monthlyTaskList[day]?.append(task)
                            }
                        } else {
                            if task.taskDay <= currentDay && day == Utils.getDay(task.taskDay) {
                                monthlyTaskList[day]?.append(task)
                            }
                        }
                        
                    }
                }
            }
        }
        SystemManager.shared.closeLoading()
        if isRefresh {
            endAppearanceTransition()
            isRefresh = false
        }
    }
    //
    func sortTask() {
        let categoryList = DataManager.shared.getCategoryOrder()
        switch currentType {
        case .Today:
            if sortType == .Category {
                taskList.sort(by: {
                    if let first = categoryList.firstIndex(of: $0.category),
                       let second = categoryList.firstIndex(of: $1.category) {
                        if first == second {
                            if $0.isDone && !$1.isDone {
                                return false
                            } else if !$0.isDone && $1.isDone {
                                return true
                            } else {
                                if $0.taskTime.isEmpty && !$1.taskTime.isEmpty {
                                    return false
                                } else if !$0.taskTime.isEmpty && $1.taskTime.isEmpty {
                                    return true
                                } else if $0.taskTime.isEmpty && $1.taskTime.isEmpty {
                                    return $0.title < $1.title
                                } else {
                                    return $0.taskTime < $1.taskTime
                                }
                            }
                        } else {
                            return first < second
                        }
                    }
                    return false
                })
            } else {
                taskList.sort(by: {
                    if $0.isDone && !$1.isDone {
                        return false
                    } else if !$0.isDone && $1.isDone {
                        return true
                    } else {
                        if $0.taskTime.isEmpty && !$1.taskTime.isEmpty {
                            return false
                        } else if !$0.taskTime.isEmpty && $1.taskTime.isEmpty {
                            return true
                        } else if $0.taskTime.isEmpty && $1.taskTime.isEmpty {
                            return $0.title < $1.title
                        } else {
                            return $0.taskTime < $1.taskTime
                        }
                    }
                })
            }
        case .Month:
            for i in taskDateKeyList {
                if let taskList = monthlyTaskList[i] {
                    monthlyTaskList[i] = taskList.sorted(by: {
                        if sortType == .Category {
                            if let first = categoryList.firstIndex(of: $0.category),
                               let second = categoryList.firstIndex(of: $1.category) {
                                if first == second {
                                    if $0.isDone && !$1.isDone {
                                        return false
                                    } else if !$0.isDone && $1.isDone {
                                        return true
                                    } else {
                                        if $0.taskTime.isEmpty && !$1.taskTime.isEmpty {
                                            return false
                                        } else if !$0.taskTime.isEmpty && $1.taskTime.isEmpty {
                                            return true
                                        } else if $0.taskTime.isEmpty && $1.taskTime.isEmpty {
                                            return $0.title < $1.title
                                        } else {
                                            return $0.taskTime < $1.taskTime
                                        }
                                    }
                                } else {
                                    return first < second
                                }
                            }
                            return false
                        } else {
                            if $0.isDone && !$1.isDone {
                                return false
                            } else if !$0.isDone && $1.isDone {
                                return true
                            } else {
                                if $0.taskTime.isEmpty && !$1.taskTime.isEmpty {
                                    return false
                                } else if !$0.taskTime.isEmpty && $1.taskTime.isEmpty {
                                    return true
                                } else if $0.taskTime.isEmpty && $1.taskTime.isEmpty {
                                    return $0.title < $1.title
                                } else {
                                    return $0.taskTime < $1.taskTime
                                }
                            }
                        }
                    })
                }
            }
        }
        calendarView.reloadData()
        reloadTable()
    }
    //
    func checkNil() {
        switch currentType {
        case .Today:
            if taskList.count == 0 {
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
    func taskIsDone(_ indexPath:IndexPath) {
        switch currentType {
        case .Today:
            //Today
            let task = taskList[indexPath.section]
            let modifyTask = task.clone()
            modifyTask.changeIsDone()
            DataManager.shared.updateTask(modifyTask)
            //
            sortTask()
            dailyTaskTable.reloadData()
        case .Month:
            //Month
            guard let taskList = monthlyTaskList[Utils.getDay(monthDate)] else {
                return
            }
            let task = taskList[indexPath.section]
            let modifyTask = task.clone()
            modifyTask.changeIsDone()
            DataManager.shared.updateTask(modifyTask)
            //
            sortTask()
            monthlyTaskTable.reloadData()
        }
    }
    //
    func deleteTask(_ indexPath:IndexPath) {
        PopupManager.shared.openYesOrNo(self, title: "TODO 삭제", msg: "TODO를 삭제하시겠습니까?") { [self] _ in
            switch currentType {
            case .Today:
                let task = taskList[indexPath.section]
                deleteTaskProcess(task)
            case .Month:
                guard let taskList = monthlyTaskList[Utils.getDay(monthDate)] else {
                    return
                }
                let task = taskList[indexPath.section]
                deleteTaskProcess(task)
            }
        }
    }
    private func deleteTaskProcess(_ task:EachTask) {
        guard let type = RepeatType(rawValue: task.repeatType) else { return }
        if type != .None {
            var actionList:[(UIAlertAction)->Void] = []
            // 모두 삭제
            actionList.append { [self] _ in
                DataManager.shared.deleteTask(task)
                refresh()
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
                refresh()
            }
            // 취소
            actionList.append { _ in
                ()
            }
            PopupManager.shared.openAlertSheet(self,
                                               title: "TODO 삭제", msg: "TODO를 삭제하시겠습니까?",
                                               btnMsg: ["모두 삭제", "이전 TODO 유지", "취소"],
                                               complete: actionList)
        } else {
            DataManager.shared.deleteTask(task)
            refresh()
        }
    }
}

//MARK: - func
extension TODOViewController {
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
extension TODOViewController {
    //SegmentedControl
    @objc private func changeSegment(_ sender:UISegmentedControl) {
        //
        switch segmentControl.selectedSegmentIndex {
        case 0:
            currentType = .Today
            btnToday.isHidden = true
        case 1:
            currentType = .Month
            btnToday.isHidden = false
        default:
            return
        }
        refresh()
    }
    @IBAction func clickTaskAdd(_ sender:Any) {
        let date = currentType == .Today ? Date() : monthDate
        isTaskOpen = true
        SystemManager.shared.openTaskInfo(.ADD, date: date, task: nil, load:{ [self] in
            loadTask()
            sortTask()
        }, modify: nil)
    }
    @IBAction func clickToday(_ sender:Any) {
        isMoveToday = true
        monthDate = Date()
        calendarView.select(monthDate)
        refresh()
        isMoveToday = false
    }
}

