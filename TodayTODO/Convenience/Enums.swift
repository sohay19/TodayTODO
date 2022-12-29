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

enum PageType:Int {
    case Main
    case Category
    case Push
    case Setting
}

enum MainType:Int {
    case Today
    case Month
}

enum SettingType:String {
    case Notice = "공지사항"
    case FAQ = "FAQ"
    case Backup = "iCloud 백업"
    case Question = "문의하기"
    case Reset = "데이터 초기화"
    case Help = "도움말"
    case Custom = "테마 및 폰트"
}

enum SortType:String {
    case Category = "카테고리 순"
    case Time = "시간 순"
}

enum DataType:String {
    case Array = "Array"
    case EachTask = "EachTask"
    case NSEachTaskList = "NSEachTaskList"
    case NSAlarmInfoList = "NSAlarmInfoList"
    case NSCategoryDataList = "NSCategoryDataList"
}

enum SendType:String {
    case Add = "add"
    case Update = "update"
    case Delete = "delete"
}

enum HelpType:String {
    case MainLeftSwipe = "Main_Today_LeftSwipe"
    case MainRightSwipe = "Main_Today_RightSwipe"
    case MainSort = "Main_Sort"
    case MainToday = "Main_Month_Today"
    case CategorySwipe = "Category_Swipe"
    case CategoryMove = "Category_Move"
    case PushSwipe = "Push_Swipe"
    case PushEdit = "Push_Edit"
}

enum FontType:String {
    case Barunpen = "NanumBarunpen"
    case SquareNeo = "NanumSquareNeo"
    case SquareRound = "NanumSquareRound"
}

//MARK: - CodingKey
enum TaskCodingKeys:String, CodingKey {
    case id
    case taskDay
    case category
    case taskTime
    case title
    case memo
    case repeatType
    case optionData
    case weekDay
    case weekOfMonth
    case isEnd
    case taskEndDate
    case isAlarm
    case alarmTime
    case isDone
}

enum CategoryCodingKeys:String, CodingKey {
    case primaryKey
    case title
    case colorList
}

enum AlarmCodingKeys:String, CodingKey {
    case taskId
    case alarmId
    case alarmTime
}
