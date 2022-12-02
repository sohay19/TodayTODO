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
    
    mutating func sortCateogry(_ list:[String]) {
        categoryList.sort {
            if let first = list.firstIndex(of: $0), let second = list.firstIndex(of: $1) {
                return first < second
            }
            return false
        }
    }
}
