//
//  Enums.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import Foundation
import SwiftUI

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
    case Eachweek = "매 주"
    case EachOnceOfMonth = "매 월"
    case EachWeekOfMonth = "매 월, 매 주"
    case EachYear = "매 년"
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

enum PushType:String {
    case Alert = "Alert"
}

enum DataType:String {
    case EachTask = "EachTask"
    case NSEachTask = "NSEachTask"
    case NSEachTaskList = "NSEachTaskList"
    case NSCategoryData = "NSCategoryData"
    case NSCategoryDataList = "NSCategoryDataList"
}

enum SendType:String {
    case Update = "update"
}

//MARK: - CodingKey


enum TaskCodingKeys:String, CodingKey {
    case id
    case taskDay
    case category
    case title
    case memo
    case repeatType
    case weekDay
    case weekOfMonth
    case isEnd
    case taskEndDate
    case isAlarm
    case alarmTime
    case isDone
}

enum CategoryCodingKeys:String, CodingKey {
    case title
    case colorList
}
