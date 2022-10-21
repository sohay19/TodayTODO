//
//  PushData.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/21.
//

import Foundation
import UserNotifications

class PushData {
    var id:String = ""
    var repeatType:RepeatType = RepeatType.None
    var alarmTime:String = ""
    var endDate:String = ""
    var requestList:[UNNotificationRequest] = []
    
    
    
    convenience init(id:String, repeatType:RepeatType, alarmTime:String, endDate:String, requestList:[UNNotificationRequest]) {
        self.init()
        self.id = id
        self.repeatType = repeatType
        self.alarmTime = alarmTime
        self.endDate = endDate
        self.requestList = requestList
    }
}
