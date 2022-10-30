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
    var id:String = ""
    //Task 날짜 (yyyy-MM-dd)
    var taskDay:String = ""
    //카테고리
    var category:String = ""
    //제목
    var title:String = ""
    //내용
    var memo:String = ""
    //반복 타입
    var repeatType:String = ""
    //반복요일 체크(일요일 = 0) -> DateComponents (일요일 = 1)
    var weekDay:[Bool] = []
    //반복 주 체크
    var monthOfWeek:Int = 0
    //종료일 여부
    var isEnd:Bool = false
    //종료일
    var taskEndDate:String = ""
    //알람 여부
    var isAlarm:Bool = false
    //알람 시간
    var alarmTime:String = ""
    //Done or Not
    var isDone:Bool = false
    
    
    // Init
    init(task:EachTask)
    {
        self.id = task.id
        self.taskDay = task.taskDay
        self.category = task.category
        self.title = task.title
        self.memo = task.memo
        self.repeatType = task.repeatType
        self.weekDay = task.getWeekDayList()
        self.monthOfWeek = task.monthOfWeek
        self.isEnd = task.isEnd
        self.taskEndDate = task.taskEndDate
        self.isAlarm = task.isAlarm
        self.alarmTime = task.alarmTime
        self.isDone = task.isDone
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TaskCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(taskDay, forKey: .taskDay)
        try container.encode(category, forKey: .category)
        try container.encode(title, forKey: .title)
        try container.encode(memo, forKey: .memo)
        try container.encode(repeatType, forKey: .repeatType)
        try container.encode(weekDay, forKey: .weekDay)
        try container.encode(monthOfWeek, forKey: .monthOfWeek)
        try container.encode(isEnd, forKey: .isEnd)
        try container.encode(taskEndDate, forKey: .taskEndDate)
        try container.encode(isAlarm, forKey: .isAlarm)
        try container.encode(alarmTime, forKey: .alarmTime)
        try container.encode(isDone, forKey: .isDone)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TaskCodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        taskDay = try container.decode(String.self, forKey: .taskDay)
        category = try container.decode(String.self, forKey: .category)
        title = try container.decode(String.self, forKey: .title)
        memo = try container.decode(String.self, forKey: .memo)
        repeatType = try container.decode(String.self, forKey: .repeatType)
        weekDay = try container.decode([Bool].self, forKey: .weekDay)
        monthOfWeek = try container.decode(Int.self, forKey: .monthOfWeek)
        isEnd = try container.decode(Bool.self, forKey: .isEnd)
        taskEndDate = try container.decode(String.self, forKey: .taskEndDate)
        isAlarm = try container.decode(Bool.self, forKey: .isAlarm)
        alarmTime = try container.decode(String.self, forKey: .alarmTime)
        isDone = try container.decode(Bool.self, forKey: .isDone)
    }
}
