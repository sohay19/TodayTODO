//
//  MonthltyDayTask.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/15.
//

import Foundation

struct MonthltyDayTask {
    var isEmpty:Bool {
        return categoryList.isEmpty
    }
    var categoryList:[String]
    var taskList:[String:[EachTask]]
    
    init() {
        categoryList = []
        taskList = [:]
    }
    
    func isContain(_ category:String) -> Bool {
        return categoryList.contains(where: {$0 == category})
    }
    
    mutating func append(_ category:String, _ task:EachTask) {
        if isContain(category) {
            taskList[category]?.append(task)
        } else {
            categoryList.append(category)
            taskList[category] = [task]
        }
    }
}
