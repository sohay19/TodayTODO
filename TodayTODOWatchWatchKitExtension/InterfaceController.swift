//
//  InterfaceController.swift
//  DailyToDoListWatch WatchKit Extension
//
//  Created by 소하 on 2022/10/24.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var taskTable: WKInterfaceTable!
    @IBOutlet weak var labelEmpty: WKInterfaceLabel!
    
    var index = 0
    private var taskList:[EachTask] = []
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
    }
    
    override func willActivate() {
        super.willActivate()
        // This method is called when watch view controller is about to be visible to user
        loadTable()
    }
}

//MARK: - data
extension InterfaceController {
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        return taskList[rowIndex]
    }
}

//MARK: - Func
extension InterfaceController {
    //
    func loadTable() {
        let receiveTaskList = DataManager.shared.getTodayTask()
        print("taskList = \(receiveTaskList.count)")
        let list = DataManager.shared.getCategoryOrder()
        taskList = receiveTaskList.sorted(by: {
            if let first = list.firstIndex(of: $0.category), let second = list.firstIndex(of: $1.category) {
                if $0.isDone && !$1.isDone {
                    return false
                } else if !$0.isDone && $1.isDone {
                    return true
                } else {
                    return first < second
                }
            }
            return false
        })
        initTable()
    }
    //
    func initTable() {
        labelEmpty.setHidden(taskList.count == 0 ? false : true)
        taskTable.setNumberOfRows(taskList.count, withRowType: "EachTaskType")
        //
        for (i, task) in taskList.enumerated() {
            guard let row = taskTable.rowController(at: i) as? TaskTableRowController else {
                return
            }
            row.updateDone = updateTask(_:_:)
            row.task = task
            row.inputCell()
        }
    }
    //
    func updateTask(_ newTask:EachTask, _ complete:()->Void) {
        DataManager.shared.updateTask(newTask)
        WatchConnectManager.shared.sendToAppTask(newTask)
        complete()
        //
        let list = DataManager.shared.getCategoryOrder()
        taskList.sort(by: {
            if let first = list.firstIndex(of: $0.category), let second = list.firstIndex(of: $1.category) {
                if $0.isDone && !$1.isDone {
                    return false
                } else if !$0.isDone && $1.isDone {
                    return true
                } else {
                    return first < second
                }
            }
            return false
        })
        initTable()
    }
}
