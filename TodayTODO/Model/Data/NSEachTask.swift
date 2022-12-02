//
//  NSEachTask.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/24.
//

import Foundation

struct NSEachTaskList: Codable {
    var taskList:[NSEachTask]
}

struct NSEachTask: Codable {
    //아이디
    var taskId:String = ""
    //Task 날짜 (yyyy-MM-dd)
    var taskDay:String = ""
    //카테고리
    var category:String = ""
    //시간
    var taskTime:String = ""
    //제목
    var title:String = ""
    //내용
    var memo:String = ""
    //반복 타입
    var repeatType:String = ""
    //부가정보
    var optionData:NSOptionData
    //Done or Not
    var isDone:Bool = false
    
    
    // Init
    init(task:EachTask)
    {
        self.taskId = task.taskId
        self.taskDay = task.taskDay
        self.category = task.category
        self.taskTime = task.taskTime
        self.repeatType = task.repeatType
        self.optionData = NSOptionData(option: task.optionData ?? OptionData())
        self.title = task.title
        self.memo = task.memo
        self.isDone = task.isDone
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TaskCodingKeys.self)
        try container.encode(taskId, forKey: .id)
        try container.encode(taskDay, forKey: .taskDay)
        try container.encode(category, forKey: .category)
        try container.encode(taskTime, forKey: .taskTime)
        try container.encode(repeatType, forKey: .repeatType)
        try container.encode(optionData, forKey: .optionData)
        try container.encode(title, forKey: .title)
        try container.encode(memo, forKey: .memo)
        try container.encode(isDone, forKey: .isDone)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TaskCodingKeys.self)
        taskId = try container.decode(String.self, forKey: .id)
        taskDay = try container.decode(String.self, forKey: .taskDay)
        category = try container.decode(String.self, forKey: .category)
        taskTime = try container.decode(String.self, forKey: .taskTime)
        repeatType = try container.decode(String.self, forKey: .repeatType)
        optionData = try container.decode(NSOptionData.self, forKey: .optionData)
        title = try container.decode(String.self, forKey: .title)
        memo = try container.decode(String.self, forKey: .memo)
        isDone = try container.decode(Bool.self, forKey: .isDone)
    }
}
