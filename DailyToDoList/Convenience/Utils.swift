//
//  Utils.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import Foundation

class Utils {
    static func dateToId(_ date:Date) -> String {
        return "taskId_\(dateToString(date))"
    }
    
    static func dateToString(_ date:Date) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        
        return dateformatter.string(from: date)
    }
    
    static func stringToDate(_ date:String) -> Date? {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        
        return dateformatter.date(from: date)
    }
    //날짜만 구하기
    static func dateToDateString(_ date:Date) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        
        return dateformatter.string(from: date)
    }
    //
    static func dateStringToDate(_ date:String) -> Date? {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        
        return dateformatter.date(from: date)
    }
    //시간만 구하기
    static func dateToTimeString(_ date:Date) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm:ss"
        
        return dateformatter.string(from: date)
    }
    //1 = 일요일
    static func stringToWeekDay(_ date:String) -> Int {
        guard let today = Utils.stringToDate(date) else {
            return 0
        }
        
        guard let weekday = Calendar.current.dateComponents([.weekday], from: today).weekday else {
            return 0
        }
        return weekday
    }
    //몇번째 주인지 구하기
    static func stringToWeekOfMonth(_ date:String) -> Int {
        guard let today = Utils.stringToDate(date) else {
            return 0
        }
        
        guard let weekOfMonth = Calendar.current.dateComponents([.weekOfMonth], from: today).weekOfMonth else {
            return 0
        }
        return weekOfMonth
    }
    //마지막 주 구하기
    static func getLastWeek(_ date:Date) -> Int {
        let curMonth = Calendar.current.dateComponents([.year, .month], from: date)
        guard let curDate = Calendar.current.date(from: curMonth) else {
            return 0
        }
        let nextMonth = Calendar.current.date(byAdding: .month, value: +1, to: curDate)!
        guard let nextDate = Calendar.current.date(byAdding: .day, value: -1, to: nextMonth) else {
            return 0
        }
        let endOfMonth = Utils.dateToString(nextDate)
        
        return stringToWeekOfMonth(endOfMonth)
    }
}
