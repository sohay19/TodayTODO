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
    
    var index = 0
    private var taskList:[EachTask] = []
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        WatchConnectManager.shared.initWatchTable = initTable(_:)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        print("willActivate")
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
}

extension InterfaceController {
    //
    func initTable(_ receiveTaskList:[EachTask]) {
        taskList = receiveTaskList.sorted(by: { task1, task2 in
            if task1.isDone {
                return task2.isDone ? true : false
            } else {
                return true
            }
        })
        taskTable.setNumberOfRows(taskList.count, withRowType: "EachTaskType")
        //
        for (i, task) in taskList.enumerated() {
            guard let row = taskTable.rowController(at: i) as? TaskTableRowController else {
                return
            }
            row.updateDone = updateTask(_:_:)
            row.task = task
            //
            row.labelTitle.setText(task.title)
            row.labelTime.setText(task.alarmTime)
            row.btnDone.setBackgroundImage(UIImage(systemName: "checkmark"))
            row.btnDone.setBackgroundColor(task.isDone ? UIColor.red : UIColor.gray)
        }
        self.willActivate()
    }
    //
    func updateTask(_ newTask:EachTask, _ complete:()->Void) {
        WatchConnectManager.shared.sendAppToTask(newTask)
        complete()
    }
}
