//
//  NSAlarmInfo.swift
//  TodayTODO
//
//  Created by 소하 on 2022/12/09.
//

import Foundation
import RealmSwift

struct NSAlarmInfoList: Codable {
    var alarmList:[NSAlarmInfo]
}

struct NSAlarmInfo : Codable {
    //
    var taskId:String
    //
    var alarmId:[String]
    //
    var alarmTime:String
    
    
    init(alarmInfo:AlarmInfo) {
        self.taskId = alarmInfo.taskId
        self.alarmId = alarmInfo.getIdList()
        self.alarmTime = alarmInfo.alarmTime
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AlarmCodingKeys.self)
        try container.encode(taskId, forKey: .taskId)
        try container.encode(alarmId, forKey: .alarmId)
        try container.encode(alarmTime, forKey: .alarmTime)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AlarmCodingKeys.self)
        taskId = try container.decode(String.self, forKey: .taskId)
        alarmId = try container.decode([String].self, forKey: .alarmId)
        alarmTime = try container.decode(String.self, forKey: .alarmTime)
    }
}
