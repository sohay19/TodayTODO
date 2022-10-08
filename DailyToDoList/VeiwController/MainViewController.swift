//
//  MainViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var labelDate: UILabel!
    
    //
    private var isRefresh = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        self.navigationItem.setHidesBackButton(true, animated: false)
        //refresh해야할것
        if isRefresh {
            isRefresh = false
        }
        //
        loadUI()
        //
        SystemManager.shared.closeLoading()
    }
}

//MARK: - UI
extension MainViewController {
    func loadUI() {
        labelDate.text = Utils.dateToDateString(Date())
    }
}

//MARK: - Func
extension MainViewController {
    func loadTask() {
        guard let dataList = DataManager.shared.getTaskDataForDay(date: Date()) else {
            print("data is zero")
            return
        }
        for data in dataList {
            print("========== \(data.id) ==========")
            print("title = \(data.title)")
            print("category = \(data.category)")
            print("date = \(data.taskDate)")
            print("isEnd = \(data.isEnd)")
            if data.isEnd {
                print("endDate = \(data.taskEndDate)")
            }
            print("repeatType = \(data.repeatType)")
            if data.repeatType != RepeatType.None.rawValue {
                print("weekDayList = \(data.weekDayList)")
                print("weekOfMonth = \(data.monthOfWeek)")
            }
            print("isAlarm = \(data.isAlarm)")
            if data.isAlarm {
                print("alarmTime = \(data.alarmTime)")
            }
            print("memo = \(data.memo)")
        }
    }
}

//MARK: - Button Event
extension MainViewController {
    @IBAction func clickTaskAdd(_ sender:Any) {
        //Loading
        SystemManager.shared.openLoading(self)
        //
        let board = UIStoryboard(name: addTaskBoard, bundle: nil)
        guard let nextVC = board.instantiateViewController(withIdentifier: addTaskBoard) as? AddTaskViewController else { return }
        guard let navigation = self.navigationController as? CustomNavigationController else {
            return
        }
        navigation.pushViewController(nextVC)
    }
    
    @IBAction func clickTodayToDo(_ sender:Any) {
        isRefresh = true
        SystemManager.shared.openLoading(self)
        viewWillAppear(true)
    }
    
    @IBAction func clickMonthToDo(_ sender:Any) {
        //Loading
        SystemManager.shared.openLoading(self)
        //
        let board = UIStoryboard(name: monthBoard, bundle: nil)
        guard let nextVC = board.instantiateViewController(withIdentifier: monthBoard) as? MonthViewController else { return }
        guard let navigation = self.navigationController as? CustomNavigationController else {
            return
        }
        navigation.pushViewController(nextVC)
    }
    
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
}

