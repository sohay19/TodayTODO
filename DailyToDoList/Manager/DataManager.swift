//
//  DataManager.swift
//  dailytimetable
//
//  Created by 소하 on 2022/09/05.
//
// App


import Foundation
import FirebaseAuth
import UserNotifications
import RealmSwift
import Realm


class DataManager {
    static let shared = DataManager()
    private init() { }
    
    private let realmManager = RealmManager()
    private let pushManager = PushManager()
}

//MARK: - Func
extension DataManager {
    func initRealm() {
        realmManager.openRealm()
    }
    //
    func setReloadMain(_ reloadMain:@escaping () -> Void) {
        realmManager.reloadMainView = reloadMain
    }
    //
    func getRealmURL() -> URL? {
        return realmManager.getRealmURL()
    }
    //
    func deleteRealm() {
        realmManager.deleteOriginFile()
    }
}

//MARK: - Task
extension DataManager {
    //ADD, Delete, Update
    func addTask(_ task:EachTask) {
        realmManager.addTask(task)
        let option = task.optionData ?? OptionData()
        let isAlarm = option.isAlarm
        if isAlarm {
            addAlarmPush(task)
        }
    }
    func updateTask(_ task:EachTask) {
        realmManager.updateTask(task)
        updateAlarmPush(task)
    }
    func deleteTask(_ task:EachTask) {
        let option = task.optionData ?? OptionData()
        let isAlarm = option.isAlarm
        if isAlarm {
            deleteAlarmPush(task.taskId)
        }
        realmManager.deleteTask(task)
    }
    //load
    func getTodayTask() -> [EachTask] {
        return realmManager.getTaskDataForDay(date: Date())
    }
    func getMonthTask(date:Date) -> [EachTask] {
        return realmManager.getTaskDataForMonth(date: date)
    }
    func getTask(_ taskId:String) -> EachTask? {
        return realmManager.getTaskData(taskId)
    }
    func getTaskCategory(category:String ) -> [EachTask] {
        return realmManager.getTaskForCategory(category)
    }
}

//MARK: - Cetegory
extension DataManager {
    //
    func addCategory(_ data:CategoryData) {
        realmManager.addCategory(data)
    }
    //load
    func loadCategory() -> [CategoryData] {
        return realmManager.loadCategory()
    }
    func getCategoryColor(_ category:String) -> UIColor {
        return realmManager.getCategoryColor(category)
    }
    //
    func deleteCategory(_ category:String) {
        realmManager.deleteCategory(category)
    }
    //
    func deleteAllCategory() {
        realmManager.deleteAllCategory()
    }
}

//MARK: - Push
extension DataManager {
    //전체 push load
    func getAllPush(_ complete: @escaping ([UNNotificationRequest]) -> Void) {
        pushManager.getAllRequest(complete)
    }
    //오늘자 push load
    func getTodayPush(_ complete: @escaping ([UNNotificationRequest]) -> Void) {
        pushManager.getAllRequest { list in
            let date = Utils.dateToDateString(Date())
            let requestList = list.filter { request in
                guard let trigger = request.trigger as? UNCalendarNotificationTrigger else {
                    return false
                }
                guard let next = trigger.nextTriggerDate() else {
                    return false
                }
                let nextDate = Utils.dateToDateString(next)
                if date == nextDate {
                    return true
                } else {
                    return false
                }
            }
            complete(requestList)
        }
    }
    // 뱃지 카운트 zero set
    func removeBadgeCnt() {
        pushManager.removeBadgeCnt()
    }
}

//MARK: - Push & Alarm
extension DataManager {
    //alarmInfo, push 모두 ADD
    func addAlarmPush(_ task:EachTask) {
        let option = task.optionData ?? OptionData()
        let alarmTime = option.alarmTime
        let idList = pushManager.addNotification(task)
        let alarmInfo = AlarmInfo(task.taskId, idList, alarmTime)
        realmManager.addAlarm(idList, alarmInfo)
    }
    //alarmInfo, push 모두 UPDATE
    func updateAlarmPush(_ task:EachTask) {
        let option = task.optionData ?? OptionData()
        let isAlarm = option.isAlarm
        //삭제
        deleteAlarmPush(task.taskId)
        //새로운 알람이 있다면 추가
        if isAlarm {
            addAlarmPush(task)
        }
    }
    //alarmInfo, push 선택 삭제
    func deleteAlarmPush(_ taskId:String, _ id:String) {
        //alarminfo 있을 때
        if let alarmInfo = realmManager.getAlarmInfo(taskId) {
            let idList = realmManager.getAlarmIdList(taskId)
            pushManager.deletePush(idList)
            realmManager.deleteAlarm(alarmInfo)
        } else {
            //alarminfo가 없을 때
            pushManager.deletePush([id])
        }
    }
    func deleteAlarmPush(_ taskId:String) {
        //alarminfo 있을 때
        if let alarmInfo = realmManager.getAlarmInfo(taskId) {
            let idList = realmManager.getAlarmIdList(taskId)
            pushManager.deletePush(idList)
            realmManager.deleteAlarm(alarmInfo)
        }
    }
    //alarmInfo, push 모두 삭제
    func deleteAllAlarmPush() {
        pushManager.deleteAllPush()
        // alarmInfo 모두 삭제
        realmManager.deleteAllAlarm()
    }
}
