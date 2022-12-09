//
//  AlarmInfo.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/14.
//

import Foundation
import RealmSwift

class AlarmInfo : Object {
    @Persisted(primaryKey: true)
    var taskId:String
    @Persisted
    var alarmIdList:List<String>
    private var alarmId:[String] {
        get {
            return alarmIdList.map{$0}
        }
        set {
            alarmIdList.removeAll()
            alarmIdList.append(objectsIn: newValue)
        }
    }
    @Persisted
    var alarmTime:String
    
    
    convenience init(_ taskId:String, _ alarmIdList:[String], _ alarmTime:String) {
        self.init()
        self.taskId = taskId
        self.alarmId = alarmIdList
        self.alarmTime = alarmTime
    }
    
    convenience init(_ alarmInfo:NSAlarmInfo) {
        self.init()
        self.taskId = alarmInfo.taskId
        self.alarmId = alarmInfo.alarmId
        self.alarmTime = alarmInfo.alarmTime
    }
    
    func getIdList() -> [String] {
        return alarmId
    }
    
    func clone() -> AlarmInfo {
        return AlarmInfo(self.taskId, self.getIdList(), self.alarmTime)
    }
}
