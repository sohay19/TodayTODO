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
    //시작 시간 (HH:mm)
    @Persisted var taskTime:String
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
    @Persisted var alarmTime:Int
            
    convenience init(taskDay:Date, taskTime:Date, endTime:Date, category:String, title:String, memo:String, repeatType:String, weekDay:[Bool], monthOfWeek:Int) {
        self.init()
        self.id = Utils.dateToId(Date())
        let date = Utils.dateToDateString(taskDay)
        self.taskDate = date
        self.taskTime = "\(date)_\(Utils.dateToTimeString(taskTime))"
        self.category = category
        self.title = title
        self.memo = memo
        self.repeatType = repeatType
        self.weekDay = weekDay
        self.monthOfWeek = monthOfWeek
        
        self.isEnd = false
        self.isAlarm = false
    }
    
    func setAlarm(_ min:Int) {
        self.isAlarm = true
        self.alarmTime = min
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
}
