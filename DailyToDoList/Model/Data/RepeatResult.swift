//
//  RepeatResult.swift
//  dailytimetable
//
//  Created by 소하 on 2022/10/06.
//

import Foundation

class RepeatResult {
    //반복 타입
    var repeatType:RepeatType
    //반복요일 체크(일요일 = 0) -> DateComponents (일요일 = 1)
    var weekDay:[Bool]
    //반복 주 체크
    var monthOfWeek:MonthOfWeek
    //종료일 여부
    var isEnd:Bool
    //종료일
    var taskEndDate:Date?
            
    
    init() {
        self.repeatType = RepeatType.None
        self.weekDay = [Bool](repeating: false, count: 7)
        self.monthOfWeek = MonthOfWeek.None
        self.isEnd = false
        self.taskEndDate = nil
    }
    
    convenience init(repeatType:RepeatType, weekDay:[Bool], monthOfWeek:MonthOfWeek, isEnd:Bool, endDate:Date?) {
        self.init()
        self.repeatType = repeatType
        self.weekDay = weekDay
        self.monthOfWeek = monthOfWeek
        self.isEnd = isEnd
        self.taskEndDate = endDate
    }
        
    func getWeekDay() -> String {
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
    
    func findWeekDay(_ index:Int) -> String {
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
}
