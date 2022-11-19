//
//  RealmManager.swift
//  dailytimetable
//
//  Created by 소하 on 2022/10/01.
//
// App & Extension

import Foundation
import RealmSwift
import Realm
import WidgetKit
import UserNotifications


class RealmManager {
    static let shared = RealmManager()
    private init() { }
    
    private let pushManager = PushManager()
    private let fileManager = FileManager.default
    //
    var realmUrl:URL?
    private var realm:Realm?
    private let realmDir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId)?.appendingPathComponent("Realm_DailyToDoList", isDirectory: true)
    //
    var watchUrl:URL?
    private var watchRealm:Realm?
    private let watchDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Realm_DailyToDoList", conformingTo: .directory)
    //
    var reloadMainView:(()->Void)?
}

//MARK: - Main
extension RealmManager {
    func openRealm() {
#if os(iOS)
        guard let realmDir = realmDir else {
            print("Path 없음")
            return
        }
        if !fileManager.fileExists(atPath: realmDir.path) {
            fileManager.createDir(realmDir) { error in
                print("create error = \(error)")
            }
        }
        do {
            let path = realmDir.appendingPathComponent("DailyToDoList.realm")
            let config = Realm.Configuration(fileURL: path)
            realm = try Realm(configuration: config)
            guard let realm = realm else {
                return
            }
            realmUrl = realm.configuration.fileURL
            if !haveDefault() {
                let newList:[Float] = Utils.FloatFromRGB(rgbValue: 0x000000, alpha: 1)
                let newCategory = CategoryData(DefaultCategory, newList)
                addCategory(newCategory)
            }
        } catch let error {
            print("Realm Open Error = \(error)")
        }
#else
        if !fileManager.fileExists(atPath: watchDir.path) {
            fileManager.createDir(watchDir) { error in
                print("create error = \(error)")
            }
        }
        do {
            let path = watchDir.appendingPathComponent("DailyToDoList.realm")
            let config = Realm.Configuration(fileURL: path)
            watchRealm = try Realm(configuration: config)
            guard let realm = watchRealm else {
                return
            }
            watchUrl = realm.configuration.fileURL
            if !haveDefault() {
                let newList:[Float] = Utils.FloatFromRGB(rgbValue: 0x000000, alpha: 1)
                let newCategory = CategoryData(DefaultCategory, newList)
                addCategory(newCategory)
            }
        } catch let error {
            print("Watch Open Error = \(error)")
        }
#endif
    }
    //
    func deleteOriginFile() {
        openRealm()
        guard let realmDir = realmDir else {
            return
        }
        fileManager.deleteDir(realmDir, nil)
    }
    //
    private func addTaskData(_ task:EachTask) {
        openRealm()
        guard let realm = realm else {
            print("realm is nil")
            return
        }
        //
        do {
            try realm.write {
                realm.add(task)
                let option = task.optionData ?? OptionData()
                let isAlarm = option.isAlarm
                let alarmTime = option.alarmTime
                if isAlarm {
                    let idList = pushManager.addNotification(task)
                    let alarmInfo = AlarmInfo(task.taskId, idList, alarmTime)
                    realm.add(alarmInfo)
                }
            }
            if #available(watchOSApplicationExtension 9.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }
        } catch {
            print("Realm add Error")
        }
    }
    //
    private func updateTaskData(_ task:EachTask) {
        openRealm()
        guard let realm = realm else {
            print("realm is nil")
            return
        }    //
        do {
            var newIdList:[String] = []
            let option = task.optionData ?? OptionData()
            if option.isAlarm {
                if let alarmInfoData = getAlarmInfo(task.taskId) {
                    let idList = getAlarmIdList(task.taskId)
                    newIdList = pushManager.updatePush(idList, task)
                    try realm.write {
                        realm.delete(alarmInfoData)
                    }
                } else {
                    newIdList = pushManager.addNotification(task)
                }
                let alarmInfo = AlarmInfo(task.taskId, newIdList, option.alarmTime)
                try realm.write {
                    realm.add(alarmInfo)
                }
            } else {
                if let alarmInfoData = getAlarmInfo(task.taskId) {
                    let idList = getAlarmIdList(task.taskId)
                    try realm.write {
                        realm.delete(alarmInfoData)
                    }
                    pushManager.deletePush(idList)
                }
            }
            try realm.write {
                realm.add(task, update: .modified)
            }
            if #available(watchOSApplicationExtension 9.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }
        } catch {
            print("Realm update Error")
        }
    }
    
    private func deleteTaskData(_ task:EachTask) {
        openRealm()
        guard let realm = realm else {
            print("realm is nil")
            return
        }
        do {
            let option = task.optionData ?? OptionData()
            if option.isAlarm {
                var alarmInfoData:AlarmInfo?
                let data =  getAlarmInfo(task.taskId)
                alarmInfoData = data
                guard let alarmInfoData = alarmInfoData else {
                    return
                }
                try realm.write {
                    realm.delete(alarmInfoData)
                }
                let idList = getAlarmIdList(task.taskId)
                pushManager.deletePush(idList)
            }
            try realm.write {
                realm.delete(task)
            }
            if #available(watchOSApplicationExtension 9.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }
        } catch {
            print("Realm delete Error")
        }
    }
}

//MARK: - Task add/update/delete (iOS)
extension RealmManager {
    func addTaskDataForiOS(_ task:EachTask) {
        addTaskData(task)
        DispatchQueue.main.async {
            WatchConnectManager.shared.sendToWatchTask()
        }
    }
    
    func updateTaskDataForiOS(_ task:EachTask) {
        updateTaskData(task)
        DispatchQueue.main.async {
            WatchConnectManager.shared.sendToWatchTask()
        }
    }
    
    func deleteTaskDataForiOS(_ task:EachTask) {
        deleteTaskData(task)
        DispatchQueue.main.async {
            WatchConnectManager.shared.sendToWatchTask()
        }
    }
}

//MARK: - Task add/update/delete (Watch)
extension RealmManager {
    func addTaskDataForWatch(_ task:EachTask) {
        addTaskData(task)
        guard let reloadMainView = reloadMainView else {
            return
        }
        DispatchQueue.main.async {
            reloadMainView()
        }
    }
    
    func updateTaskDataForWatch(_ task:EachTask) {
        updateTaskData(task)
        guard let reloadMainView = reloadMainView else {
            return
        }
        DispatchQueue.main.async {
            reloadMainView()
        }
    }
    
    func deleteTaskDataForWatch(_ task:EachTask) {
        deleteTaskData(task)
        guard let reloadMainView = reloadMainView else {
            return
        }
        DispatchQueue.main.async {
            reloadMainView()
        }
    }
}


//MARK: - Alarm/Push
extension RealmManager {
    //alarmInfo 선택 삭제
    func deleteAlarm(_ taskId:String) {
        openRealm()
        guard let realm = realm else {
            print("realm is nil")
            return
        }
        guard let alarmInfo = getAlarmInfo(taskId) else {
            return
        }
        do {
            try realm.write {
                realm.delete(alarmInfo)
            }
        } catch {
            print("delete Alarm & Push Error")
        }
    }
    //alarmInfo 모두 삭제
    func deleteAllAlarm() {
        openRealm()
        guard let realm = realm else {
            print("realm is nil")
            return
        }
        do {
            let alarmDataBase = realm.objects(AlarmInfo.self)
            try realm.write {
                realm.delete(alarmDataBase)
            }
        } catch {
            print("delete All Alarm & Push Error")
        }
    }
    //
    func getAlarmIdList(_ taskId:String) -> [String] {
        openRealm()
        guard let realm = realm else {
            print("realm is nil")
            return []
        }
        //전체 DB
        let alarmDataBase = realm.objects(AlarmInfo.self)
        guard let result = alarmDataBase.first(where: {$0.taskId == taskId}) else {
            return []
        }
        return result.alarmIdList.map{$0}
    }
    //
    func getAlarmInfo(_ id:String) -> AlarmInfo? {
        openRealm()
        guard let realm = realm else {
            print("realm is nil")
            return nil
        }
        //전체 DB
        let alarmDataBase = realm.objects(AlarmInfo.self)
        guard let result = alarmDataBase.first(where: {$0.taskId == id}) else {
            return nil
        }
        return result
    }
    //
    func getAllAlarmInfo() -> [AlarmInfo] {
        openRealm()
        guard let realm = realm else {
            print("realm is nil")
            return []
        }
        return realm.objects(AlarmInfo.self).map{$0}
    }
}

//MARK: - Task Search
extension RealmManager {
    func getTaskData(_ taskId:String) -> EachTask? {
        openRealm()
        guard let realm = realm else {
            print("realm is nil")
            return nil
        }
        //전체 DB
        let taskDataBase = realm.objects(EachTask.self)
        return taskDataBase.first { $0.taskId == taskId }
    }
    //
    func getTaskDataForDay(date:Date) -> [EachTask] {
        openRealm()
        guard let realm = realm else {
            print("realm is nil")
            return []
        }
        //해당 요일
        let weekdayIndex = Utils.getWeekDay(date)
        //해당 주
        let weekOfMonth = Utils.getWeekOfMonth(date)
        //마지막 주
        let lastWeek = Utils.getLastWeek(date)
        //전체 DB
        let taskDataBase = realm.objects(EachTask.self)
        
        let foundData = taskDataBase.filter { task in
            let today = Utils.dateToDateString(date)
            let days = today.split(separator: "-")
            let loadDays = task.taskDay.split(separator: "-")
            
            if today < task.taskDay {
                return false
            }
            
            let option = task.optionData ?? OptionData()
            let isEnd = option.isEnd
            let taskEndDate = option.taskEndDate
            let weekDayList = option.weekDayList
            switch RepeatType(rawValue:task.repeatType) {
                //매일 반복
            case .EveryDay:
                return isEnd ? taskEndDate >= Utils.dateToDateString(date) : true
                //매주 해당 요일 반복
            case .Eachweek:
                if weekDayList[weekdayIndex] {
                    return isEnd ? taskEndDate >= Utils.dateToDateString(date) : true
                } else {
                    return false
                }
                //매월 해당 일 반복
            case .EachOnceOfMonth:
                if days[2] == loadDays[2] {
                    return isEnd ? taskEndDate >= Utils.dateToDateString(date) : true
                } else {
                    return false
                }
                //매월 해당 주, 해당 요일 반복
            case .EachWeekOfMonth:
                if weekDayList[weekdayIndex] {
                    let week = option.weekOfMonth
                    if week == 6 {
                        return weekOfMonth == lastWeek
                    } else if week == weekOfMonth {
                        return isEnd ? taskEndDate >= Utils.dateToDateString(date) : true
                    } else {
                        return false
                    }
                } else {
                    return false
                }
                //매년 반복
            case .EachYear:
                if days[1] == loadDays[1] && days[2] == loadDays[2] {
                    return isEnd ? taskEndDate >= Utils.dateToDateString(date) : true
                } else {
                    return false
                }
                //반복 없음
            default:
                return task.taskDay == Utils.dateToDateString(date)
            }
            //
        }
        return foundData.map{$0}
    }
    //
    func getTaskDataForMonth(date:Date) -> [EachTask] {
        openRealm()
        guard let realm = realm else {
            print("realm is nil")
            return []
        }
        //시작 날짜
        guard let firstDate = Utils.transFirstDate(date) else {
            return []
        }
        //마지막 날짜
        guard let lastDate = Utils.transLastDate(date) else {
            return []
        }
        //전체 DB
        let taskDataBase = realm.objects(EachTask.self)
        let foundData = taskDataBase.filter { task in
            if Utils.dateToDateString(lastDate) < task.taskDay {
                return false
            }
            let today = Utils.dateToDateString(date)
            let days = today.split(separator: "-")
            let loadDays = task.taskDay.split(separator: "-")
            //
            let option = task.optionData ?? OptionData()
            let isEnd = option.isEnd
            let taskEndDate = option.taskEndDate
            //
            switch RepeatType(rawValue:task.repeatType) {
                //반복 없음
            case .None:
                return days[0] == loadDays[0] && days[1] == loadDays[1] ? true : false
                //매년 반복
            case .EachYear:
                if days[1] == loadDays[1] {
                    return isEnd ? taskEndDate >=  Utils.dateToDateString(firstDate) : true
                } else {
                    return false
                }
            default:
                //그 외 모든 반복
                return isEnd ? taskEndDate >=  Utils.dateToDateString(firstDate): true
            }
        }
        return foundData.map{$0}
    }
}

//MARK: - Category
extension RealmManager {
    func addCategory(_ data:CategoryData) {
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return
        }
        do {
            try realm.write {
                realm.add(data)
            }
            WatchConnectManager.shared.sendToWatchTask()
        } catch {
            print("Realm add Error")
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return
        }
        do {
            try realm.write {
                realm.add(data)
            }
        } catch {
            print("watch add Error")
        }
#endif
    }
    
    func loadCategory() -> [CategoryData] {
#if os(iOS)
        openRealm()
        guard let realm = realm else {
            print("realm is nil")
            return []
        }
        let categoryList = realm.objects(CategoryData.self)
        return Array(categoryList)
#else
        openRealm()
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return []
        }
        let categoryList = realm.objects(CategoryData.self)
        return Array(categoryList)
#endif
    }
    
    func getCategoryColor(_ category:String) -> UIColor {
        let categoryList = loadCategory()
        if let target = categoryList.first(where: {$0.title == category}){
            let color = Utils.getColor(target.colorList)
            return color
        } else {
            return .clear
        }
    }
    
    private func haveDefault() -> Bool {
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return false
        }
        let categoryList = realm.objects(CategoryData.self)
        guard let _ = categoryList.first(where: { $0.title == DefaultCategory }) else {
            return false
        }
        return true
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return false
        }
        let categoryList = realm.objects(CategoryData.self)
        guard let _ = categoryList.first(where: { $0.title == DefaultCategory }) else {
            return false
        }
        return true
#endif
    }
}
