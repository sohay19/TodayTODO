//
//  OptionData.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/16.
//

import Foundation
import RealmSwift

class OptionData : Object
{
    //id
    @Persisted(primaryKey: true)
    var id:String
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
    var weekOfMonth:Int
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
    
    
    
    convenience init(option:NSOptionData)
    {
        self.init()
        self.id = option.id
        self.weekDay = option.weekDay
        self.weekOfMonth = option.weekOfMonth
        self.isEnd = option.isEnd
        self.taskEndDate = option.taskEndDate
        self.isAlarm = option.isAlarm
        self.alarmTime = option.alarmTime
    }
    
    convenience init(taskId:String, weekDay:[Bool], weekOfMonth:Int, isEnd:Bool, taskEndDate:String, isAlarm:Bool, alarmTime:String) {
        self.init()
        self.id = id
        self.weekDay = weekDay
        self.weekOfMonth = weekOfMonth
        self.isEnd = isEnd
        self.taskEndDate = taskEndDate
        self.isAlarm = isAlarm
        self.alarmTime = alarmTime
    }
    
    convenience init(taskId:String, weekDay:[Bool], weekOfMonth:Int) {
        self.init()
        self.id = id
        self.weekDay = weekDay
        self.weekOfMonth = weekOfMonth
        self.isEnd = false
        self.taskEndDate = ""
        self.isAlarm = false
        self.alarmTime = ""
    }
        
     func getWeekDayList() -> [Bool] {
         return weekDay
     }
    
    func clone() -> OptionData {
        return OptionData(taskId: self.id, weekDay: self.weekDay, weekOfMonth: self.weekOfMonth, isEnd: self.isEnd, taskEndDate: self.taskEndDate, isAlarm: self.isAlarm, alarmTime: self.alarmTime)
    }
}
