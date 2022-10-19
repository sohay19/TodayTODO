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
    var currntDate:Date = Date()
    var taskList:[EachTask] = []
    var monthlyTaskList:[Int:[EachTask]] = [:]
    var haveTaskList:[Date] = []
    
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
        let sideMenuView:SideMenuView = {
            let view = SideMenuView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        self.view.addSubview(sideMenuView)
        NSLayoutConstraint.activate([
            sideMenuView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            sideMenuView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            sideMenuView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            sideMenuView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading(self)
        //버전체크
        guard #available(iOS 15, *) else {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "iOS 15이상에서만 사용가능합니다.\n[설정->일반->소프트웨어 업데이트]\n에서 업데이트해주세요.", complete: { _ in
                SystemManager.shared.openSettingMenu()
            })
        }
        DispatchQueue.main.async {
            DataManager.shared.openRealm()
        }
        //
        initDate()
        initUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //
        DispatchQueue.main.async {
            self.loadTask()
            SystemManager.shared.closeLoading()
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
        case 1:
            //Month
            monthView.isHidden = false
            todayView.isHidden = true
        default:
            //Today
            monthView.isHidden = true
            todayView.isHidden = false
        }
    }
}

//MARK: - Task
extension MainViewController {
    //Task 세팅
    func loadTask() {
        switch segmentedController.selectedSegmentIndex {
        case 1:
            // data reset
            monthlyTaskList = [:]
            guard let dataList = DataManager.shared.getTaskDataForMonth(date: currntDate) else {
                print("data is zero")
                return
            }
            //
            let tmpList = dataList.sorted { $0.taskDay < $1.taskDay }
            for task in tmpList {
                // 달력 표기를 위해 기록
                if let date = Utils.dateStringToDate(task.taskDay) {
                    haveTaskList.append(date)
                }
                // task 정리
                let day = Int(task.taskDay.split(separator: "-")[2])!
                if monthlyTaskList[day] == nil {
                    monthlyTaskList[day] = [task]
                } else {
                    monthlyTaskList[day]?.append(task)
                }
            }
            //
            guard let day = Calendar.current.dateComponents([.day], from: currntDate).day else {
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
            calendarView.reloadData()
            //
            monthlyTaskTable.reloadData()
            monthlyTaskTable.flashScrollIndicators()
        default:
            guard let dataList = DataManager.shared.getTaskDataForDay(date: currntDate) else {
                print("data is zero")
                return
            }
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
        }
        changeSegment()
    }
    //
    func taskIsDone(_ isDone:Bool, _ indexPath:IndexPath) {
        let modifyTask = taskList[indexPath.row].clone()
        modifyTask.isDone = isDone
        DataManager.shared.updateTaskData(modifyTask)
        //
        switch segmentedController.selectedSegmentIndex {
        case 1:
            //Month
            break
        default:
            //Today
            dailyTaskTable.reloadRows(at: [indexPath], with: .none)
        }
    }
    //
    func modifyTask(_ task:EachTask, _ indexPath:IndexPath) {
        DataManager.shared.updateTaskData(task)
        taskList[indexPath.row] = task
        //
        switch segmentedController.selectedSegmentIndex {
        case 1:
            //Month
            break
        default:
            //Today
            dailyTaskTable.reloadRows(at: [indexPath], with: .none)
        }
    }
    //
    func deleteTask(_ indexPath:IndexPath) {
        let task = taskList[indexPath.row]
        DataManager.shared.deleteTaskData(task)
        taskList.remove(at: indexPath.row)
        //
        switch segmentedController.selectedSegmentIndex {
        case 1:
            //Month
            break
        default:
            //Today
            dailyTaskTable.deleteRows(at: [indexPath], with: .none)
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
        case 1:
            //Month
            monthlyTaskTable.refreshControl?.endRefreshing()
            monthlyTaskTable.reloadData()
        default:
            //Today
            dailyTaskTable.refreshControl?.endRefreshing()
            dailyTaskTable.reloadData()
        }
    }
}

//MARK: - Button Event
extension MainViewController {
    @IBAction func clickTaskAdd(_ sender:Any) {
        //Loading
        SystemManager.shared.openLoading(self)
        //
        let board = UIStoryboard(name: taskInfoBoard, bundle: nil)
        guard let nextVC = board.instantiateViewController(withIdentifier: taskInfoBoard) as? TaskInfoViewController else { return }
        
        nextVC.currentMode = .ADD
        nextVC.refreshTask = loadTask
        nextVC.currntDate = currntDate
        nextVC.modalTransitionStyle = .crossDissolve
        nextVC.modalPresentationStyle = .overCurrentContext
        
        present(nextVC, animated: true)
    }
    //
    @IBAction func changeDailyTaskEditMode(_ sender:UIButton) {
        if dailyTaskTable.isEditing {
            sender.setTitle("Edit", for: .normal)
            dailyTaskTable.setEditing(false, animated: false)
        } else {
            sender.setTitle("Done", for: .normal)
            dailyTaskTable.setEditing(true, animated: false)
        }
    }
    //
    @IBAction func clickMyPage(_ sender:Any) {
        //Loading
        SystemManager.shared.openLoading(self)
        //
        let board = UIStoryboard(name: settingBoard, bundle: nil)
        guard let nextVC = board.instantiateViewController(withIdentifier: settingBoard) as? SettingViewController else { return }
        guard let navigation = self.navigationController as? CustomNavigationController else {
            return
        }
        navigation.pushViewController(nextVC)
    }
    //
    @IBAction func deleteAllNoti(_ sender:Any) {
        SystemManager.shared.deleteAllPush()
    }
    //SegmentedControl
    @IBAction func changeSegment(_ sender:UISegmentedControl) {
        changeSegment()
        DispatchQueue.main.async {
            self.loadTask()
        }
    }
}

