//
//  DayTask.swift
//  dailytimetable
//
//  Created by 소하 on 2022/08/18.
//
//Task아이디,타이틀,시간(+반복),내용,장소,사람

import Foundation
import RealmSwift

class EachTask : Object
{
    //아이디
    @Persisted(primaryKey: true)
    var taskId:String
    //Task 날짜 (yyyy-MM-dd)
    @Persisted
    var taskDay:String
    //카테고리
    @Persisted
    var category:String
    //시간
    @Persisted
    var taskTime:String
    //반복 타입
    @Persisted
    var repeatType:String
    //부가정보
    @Persisted
    var optionData:OptionData?
    //제목
    @Persisted
    var title:String
    //내용
    @Persisted
    var memo:String
    //Done or Not
    @Persisted
    var isDone:Bool
    
    
    convenience init(task:NSEachTask)
    {
        self.init()
        self.taskId = task.taskId
        self.taskDay = task.taskDay
        self.category = task.category
        self.taskTime = task.taskTime
        self.repeatType = task.repeatType
        self.optionData = OptionData(option: task.optionData)
        self.title = task.title
        self.memo = task.memo
        self.isDone = task.isDone
    }
            
    convenience init(taskDay:Date, category:String, time:String, title:String, memo:String, repeatType:String) {
        self.init()
        self.taskId = Utils.dateToId(Date())
        let date = Utils.dateToDateString(taskDay)
        self.taskDay = date
        self.category = category
        self.taskTime = time
        self.title = title
        self.memo = memo
        self.repeatType = repeatType
        self.optionData = OptionData()
        self.isDone = false
    }
    
    convenience init(id:String, taskDay:Date, category:String, time:String, title:String, memo:String, repeatType:String, optionData:OptionData) {
        self.init()
        self.taskId = id
        let date = Utils.dateToDateString(taskDay)
        self.taskDay = date
        self.category = category
        self.taskTime = time
        self.title = title
        self.memo = memo
        self.repeatType = repeatType
        self.optionData = optionData
        self.isDone = false
    }
    
    convenience init(id:String, taskDay:String, category:String, time:String, title:String, memo:String, repeatType:String, optionData:OptionData, isDone:Bool) {
        self.init()
        self.taskId = id
        self.taskDay = taskDay
        self.category = category
        self.taskTime = time
        self.title = title
        self.memo = memo
        self.repeatType = repeatType
        self.optionData = optionData
        self.isDone = isDone
    }
    
    func setOptionData(_ option:OptionData) {
        self.optionData = option
    }
    
    func stopRepeat() {
        guard let optionData = optionData else {
            return
        }
        let type:RepeatType = .None
        repeatType = type.rawValue
        optionData.repeatOff()
    }
    
    func changeIsDone() {
        self.isDone = !self.isDone
    }
    
    func setEndDate(_ endDate:Date) {
        guard let optionData = optionData else {
            return
        }
        optionData.isEnd = true
        optionData.taskEndDate = Utils.dateToDateString(endDate)
    }
    
    func getWeekDays() -> [Int] {
        guard let optionData = optionData else {
            return []
        }
        var result:[Int] = []
        let weekDay = optionData.weekDayList
        for i in 0..<weekDay.count {
            if weekDay[i] {
                result.append(i)
            }
        }
        return result
    }
   
    func getWeekDayList() -> [Bool] {
        guard let optionData = optionData else {
            return []
        }
        return optionData.getWeekDayList()
    }
    
    func printWeekDay() -> String {
        guard let optionData = optionData else {
            return ""
        }
        var result = ""
        let weekDay = optionData.weekDayList
        for i in 0..<weekDay.count {
            if weekDay[i] {
                result += "\(Utils.findWeekDay(i)), "
            }
        }
        if !result.isEmpty {
            result.removeLast()
            result.removeLast()
        }
        
        return result
    }
    
    func setAlarm(_ time:Date?) {
        guard let optionData = optionData else {
            return
        }
        if let time = time {
            optionData.isAlarm = true
            optionData.alarmTime = Utils.dateToTimeString(time)
        } else {
            optionData.isAlarm = false
            optionData.alarmTime = ""
        }
    }
    
    func setCategory(_ category:String) {
        self.category = category
    }
    
    func clone() -> EachTask {
        guard let optionData = optionData else {
            return EachTask()
        }
        return EachTask(id: self.taskId, taskDay: self.taskDay, category: self.category, time: self.taskTime, title: self.title, memo: self.memo, repeatType: self.repeatType, optionData: optionData.clone(), isDone: self.isDone)
    }
    
    func printTask() {
        guard let optionData = optionData else {
            return
        }
        print("========== \(self.taskId) ==========")
        print("title = \(self.title)")
        print("category = \(self.category)")
        print("date = \(self.taskDay)")
        print("isEnd = \(optionData.isEnd)")
        if optionData.isEnd {
            print("endDate = \(optionData.taskEndDate)")
        }
        print("repeatType = \(self.repeatType)")
        if self.repeatType != RepeatType.None.rawValue {
            print("weekDayList = \(optionData.weekDayList)")
            print("weekOfMonth = \(optionData.weekOfMonth)")
        }
        print("isAlarm = \(optionData.isAlarm)")
        if optionData.isAlarm {
            print("alarmTime = \(optionData.alarmTime)")
        }
        print("memo = \(self.memo)")
    }
}
