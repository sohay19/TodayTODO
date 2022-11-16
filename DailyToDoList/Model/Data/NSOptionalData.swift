//
//  NSOptionData.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/16.
//

import Foundation

struct NSOptionData: Codable{
    //id
    var id:String = ""
    //반복요일 체크(일요일 = 0) -> DateComponents (일요일 = 1)
    var weekDay:[Bool] = []
    //반복 주 체크
    var weekOfMonth:Int = 0
    //종료일 여부
    var isEnd:Bool = false
    //종료일
    var taskEndDate:String = ""
    //알람 여부
    var isAlarm:Bool = false
    //알람 시간
    var alarmTime:String = ""
    
    
    // Init
    init(option:OptionData)
    {
        self.id = option.id
        self.weekDay = option.getWeekDayList()
        self.weekOfMonth = option.weekOfMonth
        self.isEnd = option.isEnd
        self.taskEndDate = option.taskEndDate
        self.isAlarm = option.isAlarm
        self.alarmTime = option.alarmTime
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TaskCodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        weekDay = try container.decode([Bool].self, forKey: .weekDay)
        weekOfMonth = try container.decode(Int.self, forKey: .weekOfMonth)
        isEnd = try container.decode(Bool.self, forKey: .isEnd)
        taskEndDate = try container.decode(String.self, forKey: .taskEndDate)
        isAlarm = try container.decode(Bool.self, forKey: .isAlarm)
        alarmTime = try container.decode(String.self, forKey: .alarmTime)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TaskCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(weekDay, forKey: .weekDay)
        try container.encode(weekOfMonth, forKey: .weekOfMonth)
        try container.encode(isEnd, forKey: .isEnd)
        try container.encode(taskEndDate, forKey: .taskEndDate)
        try container.encode(isAlarm, forKey: .isAlarm)
        try container.encode(alarmTime, forKey: .alarmTime)
    }
}
