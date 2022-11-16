//
//  TaskInterfaceController.swift
//  DailyToDoListWatchWatchKitExtension
//
//  Created by 소하 on 2022/10/29.
//

import WatchKit
import Foundation
import WatchConnectivity


class TaskInterfaceController: WKInterfaceController {
    @IBOutlet weak var labelTitle: WKInterfaceLabel!
    @IBOutlet weak var labelCategory: WKInterfaceLabel!
    @IBOutlet weak var labelTime: WKInterfaceLabel!
    @IBOutlet weak var labelMemo: WKInterfaceLabel!
    
    var task:EachTask?
    
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        task = context as? EachTask
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        initTask()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
}

extension TaskInterfaceController {
    func initTask() {
        guard let task = task else {
            return
        }
        //
        labelTitle.setText(task.title)
        //
        let color = RealmManager.shared.getCategoryColor(task.category)
        labelCategory.setTextColor(color)
        labelCategory.setText(task.category)
        //
        let option = task.optionData ?? OptionData()
        let isAlarm = option.isAlarm
        let alarmTime = option.alarmTime
        //
        if isAlarm {
            labelTime.setHidden(false)
            labelTime.setText(alarmTime)
        } else {
            labelTime.setHidden(true)
        }
        //
        labelMemo.setText(task.memo)
    }
}
