//
//  TaskTableRowController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/24.
//

import Foundation
import WatchKit

class TaskTableRowController : NSObject {
    @IBOutlet weak var labelTitle:WKInterfaceLabel!
    @IBOutlet weak var labelTime:WKInterfaceLabel!
    @IBOutlet weak var btnDone: WKInterfaceButton!
    @IBOutlet weak var imgCheck: WKInterfaceImage!
    @IBOutlet weak var backGroup: WKInterfaceGroup!
    @IBOutlet weak var categoryLine: WKInterfaceGroup!
    
    var task:EachTask?
    var updateDone:((EachTask)->Void)?
}

extension TaskTableRowController {
    func inputCell() {
        guard let task = task else {
            return
        }
        backGroup.setBackgroundImage(UIImage(named: BackgroundImage))
        labelTitle.setText(task.title)
        let color = DataManager.shared.getCategoryColor(task.category)
        categoryLine.setBackgroundColor(color)
        labelTime.setText(task.taskTime.isEmpty ? "--:--" : task.taskTime)
        imgCheck.setTintColor(task.isDone ? UIColor.systemIndigo! : UIColor.gray)
    }
    
    @IBAction func clickDone() {
        guard let updateDone = updateDone, let task = task else {
            return
        }
        let newTask = task.clone()
        newTask.changeIsDone()
        updateDone(newTask)
    }
}
