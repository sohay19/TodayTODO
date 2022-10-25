//
//  InterfaceController.swift
//  DailyToDoListWatch WatchKit Extension
//
//  Created by 소하 on 2022/10/24.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var taskTable: WKInterfaceTable!
    
    var taskList:[EachTask] = []
    
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        loadTask()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
}

extension InterfaceController {
    func loadTask() {
        WatchConnectManager.shared.sendToWatchTask(initTable)
    }
    
    func initTable() {
        print("taskList.count = \(taskList.count)")
        taskTable.setNumberOfRows(taskList.count, withRowType: "EachTaskType")
        
        for (i, item) in taskList.enumerated() {
            guard let row = taskTable.rowController(at: i) as? TaskTableRowController else {
                return
            }
            row.labelTitle.setText(item.title)
            row.labelTime.setText(item.alarmTime)
        }
    }
}
