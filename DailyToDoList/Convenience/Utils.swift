//
//  Utils.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import Foundation
import UIKit
import RealmSwift

//MARK: - 날짜변환
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
    //월,일만 구하기
    static func dateToMonthDayString(_ date:Date) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MM-dd"
        
        return dateformatter.string(from: date)
    }
    //
    static func getWeekDay(_ weekDay:Int) -> String {
        var strWeekDay = ""
        
        switch weekDay {
        case 0:
            strWeekDay = "일"
        case 1:
            strWeekDay = "월"
        case 2:
            strWeekDay = "화"
        case 3:
            strWeekDay = "수"
        case 4:
            strWeekDay = "목"
        case 5:
            strWeekDay = "금"
        case 6:
            strWeekDay = "토"
        default:
            break
        }
        
        return strWeekDay
    }
    //주 한국말로
    static func getWeekOfMonthIntKOR(_ weekOfMonth:Int) -> String {
        var strWeekOfMonth = ""
        
        switch weekOfMonth {
        case 0:
            strWeekOfMonth = "없음"
        case 1:
            strWeekOfMonth = "첫째"
        case 2:
            strWeekOfMonth = "둘째"
        case 3:
            strWeekOfMonth = "셋째"
        case 4:
            strWeekOfMonth = "넷째"
        case 5:
            strWeekOfMonth = "다섯째"
        case 6:
            strWeekOfMonth = "마지막"
        default:
            break
        }
        return strWeekOfMonth
    }
}

//MARK: - 일/주/etc 구하기
extension Utils {
    //요일 구하기(0 = 일요일)
    static func getWeekDay(_ date:String) -> Int {
        guard let today = Utils.stringToDate(date) else {
            return -1
        }
        guard let weekday = Calendar.current.dateComponents([.weekday], from: today).weekday else {
            return -1
        }
        return weekday-1
    }
    static func getWeekDay(_ date:Date) -> Int {
        guard let weekday = Calendar.current.dateComponents([.weekday], from: date).weekday else {
            return -1
        }
        return weekday-1
    }
    //몇번째 주인지 구하기
    static func getWeekOfMonth(_ date:String) -> Int {
        guard let today = Utils.stringToDate(date) else {
            return 0
        }
        guard let weekOfMonth = Calendar.current.dateComponents([.weekOfMonth], from: today).weekOfMonth else {
            return 0
        }
        let lastWeek = getLastWeek(date)
        return weekOfMonth == lastWeek ? 6 : weekOfMonth
    }
    static func getWeekOfMonth(_ date:Date) -> Int {
        guard let weekOfMonth = Calendar.current.dateComponents([.weekOfMonth], from: date).weekOfMonth else {
            return 0
        }
        let lastWeek = getLastWeek(date)
        return weekOfMonth == lastWeek ? 6 : weekOfMonth
    }
    //마지막 주 구하기
    static func getLastWeek(_ date:Date) -> Int {
        let curMonth = Calendar.current.dateComponents([.year, .month], from: date)
        guard let curDate = Calendar.current.date(from: curMonth) else {
            return 0
        }
        let nextMonth = Calendar.current.date(byAdding: .month, value: +1, to: curDate)!
        guard let beforeDate = Calendar.current.date(byAdding: .day, value: -1, to: nextMonth) else {
            return 0
        }
        let endOfMonth = Utils.dateToDateString(beforeDate)
        
        return getWeekOfMonth(endOfMonth)
    }
    static func getLastWeek(_ date:String) -> Int {
        guard let curDate = dateStringToDate(date) else {
            return 0
        }
        let curMonth = Calendar.current.dateComponents([.year, .month], from: curDate)
        guard let curDate = Calendar.current.date(from: curMonth) else {
            return 0
        }
        let nextMonth = Calendar.current.date(byAdding: .month, value: +1, to: curDate)!
        guard let beforeDate = Calendar.current.date(byAdding: .day, value: -1, to: nextMonth) else {
            return 0
        }
        let endOfMonth = Utils.dateToDateString(beforeDate)
        
        return getWeekOfMonth(endOfMonth)
    }
    //마지막 일 구하기
    static func getLastDay(_ date:Date) -> Int {
        guard let firstDate = transFirstDate(date) else {
            return 0
        }
        let curMonth = Calendar.current.dateComponents([.year, .month, .day], from: firstDate)
        guard let curDate = Calendar.current.date(from: curMonth) else {
            return 0
        }
        let nextMonth = Calendar.current.date(byAdding: .month, value: +1, to: curDate)!
        guard let beforeDate = Calendar.current.date(byAdding: .day, value: -1, to: nextMonth) else {
            return 0
        }
        
        return Calendar.current.dateComponents([.day], from: beforeDate).day!
    }
    static func getLastDay(_ date:String) -> Int {
        guard let firstDate = transFirstDate(date) else {
            return 0
        }
        let curMonth = Calendar.current.dateComponents([.year, .month, .day], from: firstDate)
        guard let curDate = Calendar.current.date(from: curMonth) else {
            return 0
        }
        let nextMonth = Calendar.current.date(byAdding: .month, value: +1, to: curDate)!
        guard let beforeDate = Calendar.current.date(byAdding: .day, value: -1, to: nextMonth) else {
            return 0
        }
        
        return Calendar.current.dateComponents([.day], from: beforeDate).day!
    }
    //일 구하기
    static func getDay(_ date:String) -> Int {
        guard let curDate = dateStringToDate(date) else {
            return 0
        }
        
        return Calendar.current.dateComponents([.day], from: curDate).day!
    }
    static func getDay(_ date:Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date).day!
    }
    //월 구하기
    static func getMonth(_ date:String) -> Int {
        guard let curDate = dateStringToDate(date) else {
            return 0
        }
        return Calendar.current.dateComponents([.month], from: curDate).month!
    }
    static func getMonth(_ date:Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date).month!
    }
}

//MARK: - 변환
extension Utils {
    //
    static func transFirstDate(_ date:Date) -> Date? {
        var curDate = Utils.dateToDateString(date)
        curDate.removeLast()
        curDate.removeLast()
        curDate += "01"
        return dateStringToDate(curDate)
    }
    static func transFirstDate(_ date:String) -> Date? {
        var curDate = date
        curDate.removeLast()
        curDate.removeLast()
        curDate += "01"
        return dateStringToDate(curDate)
    }
    //
    static func transLastDate(_ date:Date) -> Date? {
        guard let firstDate = transFirstDate(date) else {
            return nil
        }
        let curMonth = Calendar.current.dateComponents([.year, .month, .day], from: firstDate)
        guard let curDate = Calendar.current.date(from: curMonth) else {
            return nil
        }
        let nextMonth = Calendar.current.date(byAdding: .month, value: +1, to: curDate)!
        guard let beforeDate = Calendar.current.date(byAdding: .day, value: -1, to: nextMonth) else {
            return nil
        }
        return beforeDate
    }
    static func transLastDate(_ date:String) -> Date? {
        guard let firstDate = transFirstDate(date) else {
            return nil
        }
        let curMonth = Calendar.current.dateComponents([.year, .month, .day], from: firstDate)
        guard let curDate = Calendar.current.date(from: curMonth) else {
            return nil
        }
        let nextMonth = Calendar.current.date(byAdding: .month, value: +1, to: curDate)!
        guard let beforeDate = Calendar.current.date(byAdding: .day, value: -1, to: nextMonth) else {
            return nil
        }
        return beforeDate
    }
    static func transNextMonth(_ date:Date) -> Date? {
        let nextMonth = Calendar.current.date(byAdding: .month, value: +1, to: date)!
        guard let firstDate = transFirstDate(nextMonth) else {
            return nil
        }
        return firstDate
    }
}

//MARK: - 일자들 반환
extension Utils {
    //요일 별 일자
    static func getWeekDayList(_ date:Date) -> [Int:[Int]] {
        let lastDate = getLastDay(date)
        guard let firstDate = transFirstDate(date) else {
            return [:]
        }
        var curDate = firstDate
        var resultList:[Int:[Int]] = [:]
        for i in 0..<7 {
            resultList[i] = []
        }
        while getMonth(curDate) == getMonth(date) && getDay(curDate) <= lastDate {
            resultList[getWeekDay(curDate)]?.append(getDay(curDate))
            curDate = Calendar.current.date(byAdding: .day, value: +1, to: curDate)!
        }
        
        return resultList
    }
    //
    static func findDay(_ date:String, _ monthOfWeek:Int, _ weekDay:[Int]) -> [Int] {
        let curDate = Calendar.current.dateComponents([.year, .month], from: dateStringToDate(date)!)
        var dateComponent = DateComponents()
        dateComponent.year = curDate.year
        dateComponent.month = curDate.month
        dateComponent.weekdayOrdinal = monthOfWeek
        
        var result:[Int] = []
        for weekday in weekDay {
            dateComponent.weekday = weekday+1
            let matchDate = Calendar.current.date(from: dateComponent)!
            result.append(getDay(matchDate))
        }
        return result
    }
    static func findDay(_ date:Date, _ monthOfWeek:Int, _ weekDay:[Int]) -> [Int] {
        let curDate = Calendar.current.dateComponents([.year, .month], from: date)
        var dateComponent = DateComponents()
        dateComponent.year = curDate.year
        dateComponent.month = curDate.month
        dateComponent.weekdayOrdinal = monthOfWeek
        
        var result:[Int] = []
        for weekday in weekDay {
            dateComponent.weekday = weekday+1
            let matchDate = Calendar.current.date(from: dateComponent)!
            result.append(getDay(matchDate))
        }
        return result
    }
}

//MARK: - Color
extension Utils {
    static func getColor(_ colorList:List<Float>) -> UIColor {
        let list = colorList.map{CGFloat($0)}
        return UIColor(red: list[0], green: list[1], blue: list[2], alpha: list[3])
    }
    
    static func UIColorFromRGB(rgbValue: UInt, alpha: CGFloat) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
    
    static func FloatFromRGB(rgbValue: UInt, alpha: CGFloat) -> [Float] {
        return [Float((rgbValue & 0xFF0000) >> 16) / 255.0, Float((rgbValue & 0x00FF00) >> 8) / 255.0, Float(rgbValue & 0x0000FF) / 255.0, Float(alpha)]
    }
}
