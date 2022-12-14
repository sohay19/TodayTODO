//
//  RepeatResult.swift
//  dailytimetable
//
//  Created by 소하 on 2022/10/06.
//

import Foundation

struct RepeatResult {
    //반복 타입
    var repeatType:RepeatType
    //반복요일 체크(일요일 = 0) -> DateComponents (일요일 = 1)
    var weekDay:[Bool]
    //반복 주 체크
    var weekOfMonth:Int
    //종료일 여부
    var isEnd:Bool
    //종료일
    var taskEndDate:Date?
            
    
    init() {
        self.repeatType = RepeatType.None
        self.weekDay = [Bool](repeating: false, count: 7)
        self.weekOfMonth = 0
        self.isEnd = false
        self.taskEndDate = nil
    }
    
    init(repeatType:RepeatType, weekDay:[Bool], weekOfMonth:Int, isEnd:Bool, endDate:Date?) {
        self.init()
        self.repeatType = repeatType
        self.weekDay = weekDay
        self.weekOfMonth = weekOfMonth
        self.isEnd = isEnd
        self.taskEndDate = endDate
    }
        
    func getWeekDay() -> String {
        var result = ""
        for i in 0..<weekDay.count {
            if weekDay[i] {
                result += "\(Utils.findWeekDay(i))/"
            }
        }
        if !result.isEmpty {
            result.removeLast()
        }
        return result
    }
}
