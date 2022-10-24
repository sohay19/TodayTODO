//
//  NSEachTask.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/24.
//

import Foundation

class NSEachTask:NSObject {
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
    convenience init(task:EachTask)
    {
        self.init()
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
    
    // Decode
    required convenience init(coder decoder: NSCoder)
    {
        self.init()
        
        if let proper_id = decoder.decodeObject(forKey: "id") as? String
        {
            self.id = proper_id
        }
        if let proper_taskDay = decoder.decodeObject(forKey: "taskDay") as? String
        {
            self.taskDay = proper_taskDay
        }
        if let proper_category = decoder.decodeObject(forKey: "category") as? String
        {
            self.category = proper_category
        }
        if let proper_title = decoder.decodeObject(forKey: "title") as? String
        {
            self.title = proper_title
        }
        if let proper_memo = decoder.decodeObject(forKey: "memo") as? String
        {
            self.memo = proper_memo
        }
        if let proper_repeatType = decoder.decodeObject(forKey: "repeatType") as? String
        {
            self.repeatType = proper_repeatType
        }
        if let proper_weekDay = decoder.decodeObject(forKey: "weekDay") as? [Bool]
        {
            self.weekDay = proper_weekDay
        }
        if let proper_monthOfWeek = decoder.decodeObject(forKey: "monthOfWeek") as? Int
        {
            self.monthOfWeek = proper_monthOfWeek
        }
        if let proper_isEnd = decoder.decodeObject(forKey: "isEnd") as? Bool
        {
            self.isEnd = proper_isEnd
        }
        if let proper_taskEndDate = decoder.decodeObject(forKey: "taskEndDate") as? String
        {
            self.taskEndDate = proper_taskEndDate
        }
        if let proper_isAlarm = decoder.decodeObject(forKey: "") as? Bool
        {
            self.isAlarm = proper_isAlarm
        }
        if let proper_alarmTime = decoder.decodeObject(forKey: "alarmTime") as? String
        {
            self.alarmTime = proper_alarmTime
        }
        if let proper_isDone = decoder.decodeObject(forKey: "isDone") as? Bool
        {
            self.isAlarm = proper_isDone
        }
    }
    
    // Encode
    func encodeWithCoder(coder : NSCoder)
    {
        let proper_id = self.id
        coder.encode(proper_id, forKey: "id")

        let proper_taskDay = self.taskDay
        coder.encode(proper_taskDay, forKey: "taskDay")

        let proper_category = self.category
        coder.encode(proper_category, forKey: "category")

        let proper_title = self.title
        coder.encode(proper_title, forKey: "title")

        let proper_memo = self.memo
        coder.encode(proper_memo, forKey: "memo")

        let proper_repeatType = self.repeatType
        coder.encode(proper_repeatType, forKey: "repeatType")

        let proper_weekDay = self.weekDay
        coder.encode(proper_weekDay, forKey: "weekDay")

        let proper_monthOfWeek = self.monthOfWeek
        coder.encode(proper_monthOfWeek, forKey: "monthOfWeek")

        let proper_isEnd = self.isEnd
        coder.encode(proper_isEnd, forKey: "isEnd")

        let proper_taskEndDate = self.taskEndDate
        coder.encode(proper_taskEndDate, forKey: "taskEndDate")

        let proper_isAlarm = self.isAlarm
        coder.encode(proper_isAlarm, forKey: "isAlarm")

        let proper_alarmTime = self.alarmTime
        coder.encode(proper_alarmTime, forKey: "alarmTime")

        let proper_isDone = self.isDone
        coder.encode(proper_isDone, forKey: "isDone")
    }
}
