//
//  Enums.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import Foundation

enum UserDataType:String {
    case None = "user"
    case Uid = "uid"
    case Email = "email"
    case Name = "name"
    case NickName = "nickName"
    case LoginType = "loginType"
}

enum LoginType:String {
    case None = "None"
    case Google = "Google"
    case Apple = "Apple"
}

enum RepeatType:String, CaseIterable {
    case None = "반복 없음"
    case EveryDay = "매일"
    case Eachweek = "매주 선택한 요일"
    case EachMonthOfOnce = "매월 같은 날"
    case EachMonthOfWeek = "매월 선택한 주, 선택한 요일"
    case EachYear = "매 년"
}

enum MonthOfWeek:Int, CaseIterable {
    case None = 0
    case First = 1
    case Second = 2
    case Third = 3
    case Fourth = 4
    case Last = 5
}

enum DataErrorType:Error {
    case None
    case AddingError
    case FetchingError
    case DeletingError
    case NoRecords
}

enum TaskMode:Int {
    case LOOK = 0
    case ADD = 1
    case MODIFY = 2
}

enum CodingKeys:String, CodingKey {
    case id
    case taskDay
    case category
    case title
    case memo
    case repeatType
    case weekDay
    case monthOfWeek
    case isEnd
    case taskEndDate
    case isAlarm
    case alarmTime
    case isDone
}
