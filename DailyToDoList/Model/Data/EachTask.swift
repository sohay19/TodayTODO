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
    @Persisted(primaryKey: true) var id:String
    //Task 날짜 (yyyy-MM-dd)
    @Persisted var taskDate:String
    //카테고리
    @Persisted var category:String
    //제목
    @Persisted var title:String
    //내용
    @Persisted var memo:String
    //반복 타입
    @Persisted var repeatType:String
    //반복요일 체크(일요일 = 0) -> DateComponents (일요일 = 1)
    @Persisted var weekDayList:List<Bool>
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
    @Persisted var monthOfWeek:Int
    //종료일 여부
    @Persisted var isEnd:Bool
    //종료일
    @Persisted var taskEndDate:String
    //알람 여부
    @Persisted var isAlarm:Bool
    //알람 시간
    @Persisted var alarmTime:String
            
    convenience init(taskDay:Date, category:String, title:String, memo:String, repeatType:String, weekDay:[Bool], monthOfWeek:Int) {
        self.init()
        self.id = Utils.dateToId(Date())
        let date = Utils.dateToDateString(taskDay)
        self.taskDate = date
        self.category = category
        self.title = title
        self.memo = memo
        self.repeatType = repeatType
        self.weekDay = weekDay
        self.monthOfWeek = monthOfWeek
        
        self.isEnd = false
        self.isAlarm = false
    }
    
    func setAlarm(_ time:Date) {
        self.isAlarm = true
        self.alarmTime = Utils.dateToTimeString(time)
    }
    
    func setEndDate(_ endDate:Date) {
        self.isEnd = true
        self.taskEndDate = Utils.dateToString(endDate)
    }
    
    func unRepeat() {
        weekDayOff()
        monthWeekOff()
    }
    
    func weekDayOff() {
        weekDay[0..<weekDay.count] = [false]
    }
    
    func monthWeekOff() {
        monthOfWeek = 0
    }
    
    func printTask() {
        print("========== \(self.id) ==========")
        print("title = \(self.title)")
        print("category = \(self.category)")
        print("date = \(self.taskDate)")
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
