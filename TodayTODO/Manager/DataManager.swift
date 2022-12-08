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
import WidgetKit


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
        WatchConnectManager.shared.sendToAppTask(.Add, task)
#if os(iOS)
        if #available(watchOSApplicationExtension 9.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
#endif
    }
    func updateTask(_ task:EachTask) {
        realmManager.updateTask(task)
        updateAlarmPush(task)
        WatchConnectManager.shared.sendToAppTask(.Update, task)
#if os(iOS)
        if #available(watchOSApplicationExtension 9.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
#endif
    }
    func deleteTask(_ task:EachTask) {
        let option = task.optionData ?? OptionData()
        let isAlarm = option.isAlarm
        if isAlarm {
            deleteAlarmPush(task.taskId)
        }
        realmManager.deleteTask(task)
        WatchConnectManager.shared.sendToAppTask(.Delete, task)
#if os(iOS)
        if #available(watchOSApplicationExtension 9.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
#endif
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
        WatchConnectManager.shared.sendToWatchCategory(.Add, data)
    }
    //load
    func loadCategory() -> [CategoryData] {
        return realmManager.loadCategory()
    }
    //
    func deleteCategory(_ category:String) {
        realmManager.deleteCategory(category)
        //
        var newList = DataManager.shared.getCategoryOrder()
        if let index = newList.firstIndex(of: category) {
            newList.remove(at: index)
        }
        setCategoryOrder(newList)
        WatchConnectManager.shared.sendToWatchCategory(.Delete, data)
    }
    func deleteCategory(_ category:CategoryData) {
        realmManager.deleteCategory(category)
        //
        var newList = DataManager.shared.getCategoryOrder()
        if let index = newList.firstIndex(of: category.title) {
            newList.remove(at: index)
        }
        setCategoryOrder(newList)
    }
    //
    func deleteAllCategory() {
        realmManager.deleteAllCategory()
        setCategoryOrder([String]())
    }
    /* ORDER */
    func reloadCategoryOrder() {
        let list = realmManager.getCategoryOrder()
        // 기존에 CategoryOrderData가 없었다면 UserDefults 사용
        if list.count == 0 {
            let newOrder = CategoryOrderData(order: getCategoryOrder())
            realmManager.setCategoryOrder(newOrder)
            return
        }
        setCategoryOrderUser(list)
    }
    func getCategoryOrder() -> [String] {
        guard let list = UserDefaults.shared.array(forKey: CategoryList) as? [String] else {
            return []
        }
        return list
    }
    func setCategoryOrder(_ list:[String]) {
        setCategoryOrderUser(list)
        setCategoryOrderRealm(list)
    }
    //set
    func setCategoryOrderUser(_ list:[String]) {
        UserDefaults.shared.set(list, forKey: CategoryList)
    }
    func setCategoryOrderRealm(_ list:[String]) {
        let categoryOrder = CategoryOrderData(order: list)
        realmManager.setCategoryOrder(categoryOrder)
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
    func updateAlarmPush(_ taskId:String, removeId:String) {
        //해당 푸쉬만 삭제
        pushManager.deletePush([removeId])
        //alarmInfo 업데이트
        realmManager.updateAlarm(taskId, removeId)
    }
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
