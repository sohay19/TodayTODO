//
//  OpenedTask.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/15.
//

import Foundation

struct OpenedTask {
    var taskId:String
    var section:String
    var indexPath:IndexPath
    
    init() {
        taskId = ""
        section = ""
        indexPath = IndexPath()
    }
    
    init(_ id:String, _ section:String, _ indexPath:IndexPath) {
        self.taskId = id
        self.section = section
        self.indexPath = indexPath
    }
}
