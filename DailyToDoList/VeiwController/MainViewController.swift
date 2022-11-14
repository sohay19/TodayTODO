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
    var currentDate:Date = Date()
    var beforeDate:Date = Date()
    //
    var taskList:[EachTask] = []
    //key = 일자
    var monthlyTaskList:[Int:[EachTask]] = [:]
    var taskDateKeyList:[Int] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //뒤로 버튼 없애기
        self.navigationItem.setHidesBackButton(true, animated: false)
        //
        dailyTaskTable.dataSource = self
        dailyTaskTable.delegate = self
        monthlyTaskTable.dataSource = self
        monthlyTaskTable.delegate = self
        calendarView.dataSource = self
        calendarView.delegate = self
        //
        initUI()
        // 리프레시 컨트롤러 초기화
        initRefreshController()
        // 메인 리로드 함수
        RealmManager.shared.reloadMainView = viewWillAppear(_:)
        //메뉴
        SystemManager.shared.openMenu(self)
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
            initDate()
            changeSegment()
        }
    }
}

//MARK: - UI
extension MainViewController {
    func initDate() {
        var date = Utils.dateToDateString(Date()).split(separator: "-")
        if segmentedController.selectedSegmentIndex != 0 {
            date.removeLast()
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
        btnAdd.titleLabel?.font = UIFont(name: LogoFont, size: E_N_FontSize + 3.0)
        labelDate.font = UIFont(name: E_N_Font_E, size: MenuFontSize)
        labelTodayNilMsg.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelMonthNilMsg.font = UIFont(name: K_Font_R, size: K_FontSize)
        //
        dailyTaskTable.backgroundColor = .clear
        dailyTaskTable.separatorInsetReference = .fromCellEdges
        dailyTaskTable.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        dailyTaskTable.separatorColor = .label
        monthlyTaskTable.backgroundColor = .clear
        monthlyTaskTable.separatorInsetReference = .fromCellEdges
        monthlyTaskTable.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        monthlyTaskTable.separatorColor = .label
        //
        monthView.isHidden = true
    }
    
    func changeSegment() {
        //
        imgUnderline.image = UIImage(named: segmentedController.selectedSegmentIndex == 0 ? Underline_Pink : Underline_Indigo)
        imgUnderline.alpha = 0.3
        //
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
            checkNil()
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
            var compareDay = Utils.dateToDateString(currentDate).split(separator: "-").map{String($0)}
            //반복 타입 별 체크
            for task in tmpList {
                switch RepeatType(rawValue: task.repeatType) {
                case .None:
                    let day = Utils.getDay(task.taskDay)
                    monthlyTaskList[day]?.append(task)
                case .EveryDay:
                    for day in taskDateKeyList {
                        compareDay[2] = String(format: "%02d", day)
                        let currentDay = compareDay.joined(separator: "-")
                        if task.isEnd {
                            if task.taskEndDate >= currentDay && task.taskDay <= currentDay {
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
                            if task.isEnd {
                                if task.taskEndDate >= currentDay && task.taskDay <= currentDay {
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
                    let daysList = Utils.findDay(currentDate, task.weekOfMonth, task.getWeekDays())
                    for day in daysList {
                        compareDay[2] = String(format: "%02d", day)
                        let currentDay = compareDay.joined(separator: "-")
                        if task.isEnd {
                            if task.taskEndDate >= currentDay && task.taskDay <= currentDay {
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
                        
                        if task.isEnd {
                            if task.taskEndDate >= currentDay && task.taskDay <= currentDay && day == Utils.getDay(task.taskDay) {
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
            //month가 바뀌었으므로 캘린더 리로드
            calendarView.reloadData()
            //
            changeDay()
        default:
            break
        }
        DispatchQueue.main.async {
            SystemManager.shared.closeLoading()
        }
    }
    //
    func checkNil() {
        if taskList.count == 0 {
            labelTodayNilMsg.isHidden = false
        } else {
            labelTodayNilMsg.isHidden = true
        }
    }
    // 선택된 날짜에 맞는 테이블 로드
    func changeDay() {
        guard let day = Calendar.current.dateComponents([.day], from: currentDate).day else {
            return
        }
        guard let monthlyTaskList = monthlyTaskList[day] else {
            return
        }
        if monthlyTaskList.count == 0 {
            labelMonthNilMsg.isHidden = false
            taskList = []
        } else {
            labelMonthNilMsg.isHidden = true
            taskList = monthlyTaskList.sorted(by: { task1, task2 in
                if task1.isDone {
                    return task2.isDone ? true : false
                } else {
                    return true
                }
            })
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
    func modifyTask(_ indexPath:IndexPath) {
        let beforeTask = taskList[indexPath.row]
        openTaskInfo(.MODIFY, beforeTask) { [self] task in
            //
            RealmManager.shared.updateTaskDataForiOS(task)
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
    //TaskInfo
    func openTaskInfo(_ mode:TaskMode, _ task:EachTask?, _ modify:((EachTask)->Void)?) {
        let board = UIStoryboard(name: taskInfoBoard, bundle: nil)
        guard let taskInfoVC = board.instantiateViewController(withIdentifier: taskInfoBoard) as? TaskInfoViewController else { return }
        //
        taskInfoVC.currentMode = mode
        taskInfoVC.refreshTask = loadTask
        taskInfoVC.modifyTask = modify
        //
        taskInfoVC.taskData = task
        taskInfoVC.modalTransitionStyle = .coverVertical
        taskInfoVC.modalPresentationStyle = .fullScreen
        
        guard let navaigatiocn = self.navigationController as? CustomNavigationController else {
            return
        }
        navaigatiocn.pushViewController(taskInfoVC)
    }
}

//MARK: - Button Event
extension MainViewController {
    @IBAction func clickTaskAdd(_ sender:Any) {
        let board = UIStoryboard(name: taskInfoBoard, bundle: nil)
        guard let nextVC = board.instantiateViewController(withIdentifier: taskInfoBoard) as? TaskInfoViewController else { return }
        //
        nextVC.currentMode = .ADD
        nextVC.refreshTask = loadTask
        nextVC.currntDate = currentDate
        //
        nextVC.modalTransitionStyle = .coverVertical
        nextVC.modalPresentationStyle = .fullScreen
        
        guard let navaigatiocn = self.navigationController as? CustomNavigationController else {
            return
        }
        navaigatiocn.pushViewController(nextVC)
    }
    //SegmentedControl
    @IBAction func changeSegment(_ sender:UISegmentedControl) {
        currentDate = Date()
        calendarView.select(currentDate)
        //
        SystemManager.shared.openLoading()
        //
        beginAppearanceTransition(true, animated: true)
        viewWillAppear(true)
    }
}

