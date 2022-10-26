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
    
    var task:EachTask?
    var updateDone:((EachTask, ()->Void)->Void)?
}

extension TaskTableRowController {
    @IBAction func clickDone() {
        guard let updateDone = updateDone, let task = task else {
            return
        }
        task.changeIsDone()
        updateDone(task) {
            btnDone.setBackgroundColor(task.isDone ? UIColor.red : UIColor.gray)
        }
    }
}
