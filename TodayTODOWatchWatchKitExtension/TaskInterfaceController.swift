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
    @IBOutlet weak var backGroup: WKInterfaceGroup!
    @IBOutlet weak var categoryGroup: WKInterfaceGroup!
    @IBOutlet weak var labelCategory: WKInterfaceLabel!
    @IBOutlet weak var labelTime: WKInterfaceLabel!
    @IBOutlet weak var labelMemo: WKInterfaceLabel!
    
    var task:EachTask?
    
    //MARK: - data
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        initCell()
        if let task = context as? EachTask {
            self.task = task
        }
    }
    
    override func willActivate() {
        super.willActivate()
        // This method is called when watch view controller is about to be visible to user
        inputCell()
    }
}


extension TaskInterfaceController {
    func initCell() {
        backGroup.setBackgroundImage(UIImage(named: BackgroundImage))
        categoryGroup.setCornerRadius(5)
        labelCategory.setTextColor(.white)
    }
    
    func inputCell() {
        guard let task = task else {
            return
        }
        labelTitle.setText(task.title)
        labelTime.setText(task.taskTime.isEmpty ? "--:--" : task.taskTime)
        labelCategory.setText(task.category)
        //
        let color = DataManager.shared.getCategoryColor(task.category)
        categoryGroup.setBackgroundColor(color)
        //
        labelMemo.setText(task.memo)
    }
}
