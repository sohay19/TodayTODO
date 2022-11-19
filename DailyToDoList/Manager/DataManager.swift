//
//  DataManager.swift
//  dailytimetable
//
//  Created by 소하 on 2022/09/05.
//
// App


import UIKit
import Foundation
import FirebaseAuth
import UserNotifications
import RealmSwift
import Realm


class DataManager {
    static let shared = DataManager()
    private init() { }
    
    private let realmManager = RealmManager()
#if os(iOS)
    private let cloudManager = CloudManager()
#endif
    private let pushManager = PushManager()
}

//MARK: - Func
extension DataManager {
    func initRealm() {
        realmManager.openRealm()
    }
    func setReloadMain(_ reloadMain:@escaping () -> Void) {
        realmManager.reloadMainView = reloadMain
    }
}
#if os(iOS)
//MARK: - iCloud
extension DataManager {
    //
    func getAllBackupFile() -> [(String, URL)] {
        cloudManager.realmUrl = realmManager.realmUrl
        return cloudManager.getAllBackupFile()
    }
    //
    func updateCloud(label:UILabel) {
        cloudManager.realmUrl = realmManager.realmUrl
        cloudManager.updateDate(label)
    }
    //
    func iCloudBackup(_ vc:UIViewController) {
        cloudManager.realmUrl = realmManager.realmUrl
        cloudManager.backUpFile(vc)
    }
    //
    func iCloudLoadFile(_ vc:UIViewController, _ url:URL) {
        cloudManager.realmUrl = realmManager.realmUrl
        cloudManager.loadBackupFile(vc, url)
    }
    func iCloudLoadRecentlyFile(_ vc:UIViewController) {
        cloudManager.realmUrl = realmManager.realmUrl
        cloudManager.loadRecentlyBackupFile(vc)
    }
    //
    func deleteiCloudBackupFile(_ url:URL) {
        cloudManager.realmUrl = realmManager.realmUrl
        cloudManager.deleteBackupFile(url)
    }
    func deleteiCloudAllBackupFile() {
        cloudManager.realmUrl = realmManager.realmUrl
        cloudManager.deleteAllBackupFile()
    }
    func deleteAllFile() {
        deleteiCloudAllBackupFile()
        realmManager.deleteOriginFile()
        deleteAllAlarmPush()
    }
}
#endif

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
            let idList = realmManager.getAlarmIdList(task.taskId)
            deletePush(idList)
            realmManager.deleteAlarm(task.taskId)
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
    // 푸시만 삭제
    private func deletePush(_ idList:[String]) {
        pushManager.deletePush(idList)
    }
    private func deletePush(_ id:String) {
        pushManager.deletePush([id])
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
        //기존 푸시가 있다면 삭제
        var idList = realmManager.getAlarmIdList(task.taskId)
        idList = pushManager.updatePush(idList, task)
        //기존 알람이 있다면 삭제
        realmManager.deleteAlarm(task.taskId)
        //새로운 알람이 있다면 추가
        if isAlarm {
            addAlarmPush(task)
        }
    }
    //alarmInfo, push 선택 삭제
    func deleteAlarmPush(_ taskId:String, _ id:String) {
        let idList = realmManager.getAlarmIdList(taskId)
        //alarminfo가 없을 때
        if idList.isEmpty {
            deletePush(id)
            return
        }
        pushManager.deletePush(idList)
        // alarmInfo 삭제
        realmManager.deleteAlarm(taskId)
    }
    func deleteAlarmPush(_ taskId:String) {
        let idList = realmManager.getAlarmIdList(taskId)
        pushManager.deletePush(idList)
        // alarmInfo 삭제
        realmManager.deleteAlarm(taskId)
    }
    //alarmInfo, push 모두 삭제
    func deleteAllAlarmPush() {
        pushManager.deleteAllPush()
        // alarmInfo 모두 삭제
        realmManager.deleteAllAlarm()
    }
}
