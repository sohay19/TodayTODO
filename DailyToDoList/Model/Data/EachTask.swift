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
    var id:String
    //Task 날짜 (yyyy-MM-dd)
    @Persisted
    var taskDay:String
    //카테고리
    @Persisted
    var category:String
    //제목
    @Persisted
    var title:String
    //내용
    @Persisted
    var memo:String
    //반복 타입
    @Persisted
    var repeatType:String
    //반복요일 체크(일요일 = 0) -> DateComponents (일요일 = 1)
    @Persisted
    var weekDayList:List<Bool>
    private var weekDay:[Bool] {
        get {
            return weekDayList.map{$0}
        }
        set {
            weekDayList.removeAll()
            weekDayList.append(objectsIn: newValue)
        }
    }
    //반복 주 체크
    @Persisted
    var monthOfWeek:Int
    //종료일 여부
    @Persisted
    var isEnd:Bool
    //종료일
    @Persisted
    var taskEndDate:String
    //알람 여부
    @Persisted
    var isAlarm:Bool
    //알람 시간
    @Persisted
    var alarmTime:String
    //Done or Not
    @Persisted
    var isDone:Bool
    
    
    convenience init(task:NSEachTask)
    {
        self.init()
        self.id = task.id
        self.taskDay = task.taskDay
        self.category = task.category
        self.title = task.title
        self.memo = task.memo
        self.repeatType = task.repeatType
        self.weekDay = task.weekDay
        self.monthOfWeek = task.monthOfWeek
        self.isEnd = task.isEnd
        self.taskEndDate = task.taskEndDate
        self.isAlarm = task.isAlarm
        self.alarmTime = task.alarmTime
        self.isDone = task.isDone
    }
    
            
    convenience init(taskDay:Date, category:String, title:String, memo:String, repeatType:String, weekDay:[Bool], monthOfWeek:Int) {
        self.init()
        self.id = Utils.dateToId(Date())
        let date = Utils.dateToDateString(taskDay)
        self.taskDay = date
        self.category = category
        self.title = title
        self.memo = memo
        self.repeatType = repeatType
        self.weekDay = weekDay
        self.monthOfWeek = monthOfWeek
        //
        self.isEnd = false
        self.isAlarm = false
        self.isDone = false
    }
    
    convenience init(id:String, taskDay:Date, category:String, title:String, memo:String, repeatType:String, weekDay:[Bool], monthOfWeek:Int) {
        self.init()
        self.id = id
        let date = Utils.dateToDateString(taskDay)
        self.taskDay = date
        self.category = category
        self.title = title
        self.memo = memo
        self.repeatType = repeatType
        self.weekDay = weekDay
        self.monthOfWeek = monthOfWeek
        //
        self.isEnd = false
        self.isAlarm = false
        self.isDone = false
    }
    
    convenience init(id:String, taskDay:String, category:String, title:String, memo:String, repeatType:String, weekDay:[Bool], monthOfWeek:Int, isEnd:Bool, taskEndDate:String, isAlarm:Bool, alarmTime:String, isDone:Bool) {
        self.init()
        self.id = id
        self.taskDay = taskDay
        self.category = category
        self.title = title
        self.memo = memo
        self.repeatType = repeatType
        self.weekDay = weekDay
        self.monthOfWeek = monthOfWeek
        self.isEnd = isEnd
        self.taskEndDate = taskEndDate
        self.isAlarm = isAlarm
        self.alarmTime = alarmTime
        self.isDone = isDone
    }
    
    func setAlarm(_ time:Date) {
        self.isAlarm = true
        self.alarmTime = Utils.dateToTimeString(time)
    }
    
    func setEndDate(_ endDate:Date) {
        self.isEnd = true
        self.taskEndDate = Utils.dateToDateString(endDate)
    }
    
    func unRepeat() {
        weekDayOff()
        monthWeekOff()
    }
    
    private func findWeekDay(_ index:Int) -> String {
        var weekDay = ""
        
        switch index {
        case 0:
            weekDay = "일"
        case 1:
            weekDay = "월"
        case 2:
            weekDay = "화"
        case 3:
            weekDay = "수"
        case 4:
            weekDay = "목"
        case 5:
            weekDay = "금"
        case 6:
            weekDay = "토"
        default:
            break
        }
        
        return weekDay
    }
    
    func getWeekDays() -> [Int] {
        var result:[Int] = []
        for i in 0..<weekDay.count {
            if weekDay[i] {
                result.append(i)
            }
        }
        return result
    }
   
    func getWeekDayList() -> [Bool] {
        return weekDay
    }
    
    func printWeekDay() -> String {
        var result = ""
        for i in 0..<weekDay.count {
            if weekDay[i] {
                result += "\(findWeekDay(i)), "
            }
        }
        
        if !result.isEmpty {
            result.removeLast()
            result.removeLast()
        }
        
        return result
    }
    
    func weekDayOff() {
        weekDay[0..<weekDay.count] = [false]
    }
    
    func monthWeekOff() {
        monthOfWeek = 0
    }
    
    func clone() -> EachTask {
        return EachTask(id: self.id, taskDay: self.taskDay, category: self.category, title: self.title, memo: self.memo, repeatType: self.repeatType, weekDay: self.weekDay, monthOfWeek: self.monthOfWeek, isEnd: self.isEnd, taskEndDate: self.taskEndDate, isAlarm: self.isAlarm, alarmTime: self.alarmTime, isDone: self.isDone)
    }
    
    func printTask() {
        print("========== \(self.id) ==========")
        print("title = \(self.title)")
        print("category = \(self.category)")
        print("date = \(self.taskDay)")
        print("isEnd = \(self.isEnd)")
        if self.isEnd {
            print("endDate = \(self.taskEndDate)")
        }
        print("repeatType = \(self.repeatType)")
        if self.repeatType != RepeatType.None.rawValue {
            print("weekDayList = \(self.weekDayList)")
            print("weekOfMonth = \(self.monthOfWeek)")
        }
        print("isAlarm = \(self.isAlarm)")
        if self.isAlarm {
            print("alarmTime = \(self.alarmTime)")
        }
        print("memo = \(self.memo)")
    }
}
