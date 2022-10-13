//
//  MainViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var taskTableView: UITableView!
    
    //
    private var isRefresh = false
    private var taskList:[EachTask] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskTableView.dataSource = self
        taskTableView.delegate = self
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
        loadTodayDate()
        //
        DispatchQueue.main.async {
            self.loadTask()
        }
    }
}

//MARK: - TableView
extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        taskCell.labelTitle.text = taskList[indexPath.row].title
        let isDone = taskList[indexPath.row].isDone
        taskCell.accessoryType = isDone ? .checkmark : .none
        
        return taskCell
    }
    //왼쪽 스와이프
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "삭제") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.deleteTask(indexPath)
            success(true)
        }
        delete.backgroundColor = .systemRed
        //index = 0, 왼쪽
        return UISwipeActionsConfiguration(actions:[delete])
    }
    //오른쪽 스와이프
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Done Or Not
        let done = UIContextualAction(style: .normal, title: "Done") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.taskIsDone(true, indexPath)
            success(true)
        }
        done.backgroundColor = .systemIndigo
        
        let notDone = UIContextualAction(style: .normal, title: "Not") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.taskIsDone(false, indexPath)
            success(true)
        }
        notDone.backgroundColor = .systemGray
        //index = 0, 오른쪽
        return UISwipeActionsConfiguration(actions:[notDone, done])
    }
    //Row별 EditMode
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if taskList[indexPath.row].isDone {
            taskTableView.cellForRow(at: indexPath)?.editingAccessoryType = .checkmark
        }
        
        return .delete
    }
    //EditMode별 Event
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteTask(indexPath)
        }
    }
    //cell별 이동 가능 여부
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return taskList[indexPath.row].isDone ? false : true
    }
    //Row Move
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let task = taskList[sourceIndexPath.row]
        taskList.remove(at: sourceIndexPath.row)
        taskList.insert(task, at: destinationIndexPath.row)
    }
}


//MARK: - UI
extension MainViewController {
    func loadTodayDate() {
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
        print("task count = \(dataList.count)")
        taskList = dataList.sorted(by: { task1, task2 in
            if task1.isDone {
                return task2.isDone ? true : false
            } else {
                return true
            }
        })
        //
        if taskList.count == 0 {
            
        } else {
            
        }
        //
        taskTableView.reloadData()
        //
        SystemManager.shared.closeLoading()
    }
    //
    func refreshPage() {
        isRefresh = true
        SystemManager.shared.openLoading(self)
        viewWillAppear(true)
    }
    //
    func taskIsDone(_ isDone:Bool, _ indexPath:IndexPath) {
        let modifyTask = taskList[indexPath.row].clone()
        modifyTask.isDone = isDone
        DataManager.shared.updateTaskData(modifyTask)
        //
        taskTableView.reloadRows(at: [indexPath], with: .none)
    }
    //
    func modifyTask(_ task:EachTask, _ indexPath:IndexPath) {
        DataManager.shared.updateTaskData(task)
        taskList[indexPath.row] = task
        //
        taskTableView.reloadRows(at: [indexPath], with: .none)
    }
    //
    func deleteTask(_ indexPath:IndexPath) {
        let task = taskList[indexPath.row]
        DataManager.shared.deleteTaskData(task)
        taskList.remove(at: indexPath.row)
        //
        taskTableView.deleteRows(at: [indexPath], with: .none)
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
        nextVC.refreshTask = loadTask
        navigation.pushViewController(nextVC)
    }
    
    @IBAction func changeEditMode(_ sender:UIButton) {
        if taskTableView.isEditing {
            sender.setTitle("Edit", for: .normal)
            taskTableView.setEditing(false, animated: false)
        } else {
            sender.setTitle("Done", for: .normal)
            taskTableView.setEditing(true, animated: false)
        }
    }
    
    @IBAction func clickTodayToDo(_ sender:Any) {
        refreshPage()
    }
    
    @IBAction func clickMonthToDo(_ sender:Any) {
        
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
    
    @IBAction func deleteAllNoti(_ sender:Any) {
        SystemManager.shared.deleteAllPush()
    }
}

