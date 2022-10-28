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


class RealmManager {
    static let shared = RealmManager()
    private init() { }
    
    private let fileManager = FileManager.default
    private let realmDir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId)?.appendingPathComponent("Realm_DailyToDoList", isDirectory: true)
    
    private var realm:Realm?
    var realmUrl:URL?
    //
    var reloadMainView:((Bool)->Void)?
}

//MARK: - Main
extension RealmManager {
    func openRealm() {
        guard let realmDir = realmDir else {
            print("realmDir 없음")
            return
        }
        if !fileManager.fileExists(atPath: realmDir.path) {
            fileManager.createDir(realmDir) { error in
                print("create error = \(error)")
            }
        }
        do {
            let path = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupId)?.appendingPathComponent("Realm_DailyToDoList", isDirectory: true).appendingPathComponent("DailyToDoList.realm")
            let config = Realm.Configuration(fileURL: path)
            realm = try Realm(configuration: config)
        } catch let error {
            print("Realm Open Error = \(error)")
        }
        //
        guard let realm = realm else {
            return
        }
        realmUrl = realm.configuration.fileURL
        //
        if !haveDefault() {
            let newList:[Float] = Utils.FloatFromRGB(rgbValue: 0xBDBDBD, alpha: 1)
            let newCategory = CategoryData("Default", newList)
            addCategory(newCategory)
        }
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
                if task.isAlarm {
                    let idList = PushManager.shared.addNotification(task)
                    let alarmInfo = AlarmInfo(task.id, idList, task.alarmTime)
                    realm.add(alarmInfo)
                }
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
            if task.isAlarm {
                if let alarmInfoData = getAlarmInfo(task.id) {
                    let idList = getAlarmIdList(task.id)
                    newIdList = PushManager.shared.updatePush(idList, task)
                    try realm.write {
                        realm.delete(alarmInfoData)
                    }
                } else {
                    newIdList = PushManager.shared.addNotification(task)
                }
                let alarmInfo = AlarmInfo(task.id, newIdList, task.alarmTime)
                try realm.write {
                    realm.add(alarmInfo)
                }
            }
            try realm.write {
                realm.add(task, update: .modified)
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
            if task.isAlarm {
                print("task.isAlarm = \(task.isAlarm)")
                var alarmInfoData:AlarmInfo?
                let data =  getAlarmInfo(task.id)
                alarmInfoData = data
                print("data IN!")
                guard let alarmInfoData = alarmInfoData else {
                    return
                }
                print("alarmInfoData = \(alarmInfoData)")
                try realm.write {
                    realm.delete(alarmInfoData)
                    print("alarmInfoData is delete")
                }
                let idList = getAlarmIdList(task.id)
                PushManager.shared.deletePush(idList)
                print("deletePrush")
            }
            try realm.write {
                print("complete")
                realm.delete(task)
            }
            WatchConnectManager.shared.sendToWatchTask()
        } catch {
            print("Realm delete Error")
        }
    }
}

//MARK: - Task add/update/delete (iOS)
extension RealmManager {
    func addTaskDataIniOS(_ task:EachTask) {
        addTaskData(task)
        DispatchQueue.main.async {
            WatchConnectManager.shared.sendToWatchTask()
        }
    }
    
    func updateTaskDataIniOS(_ task:EachTask) {
        updateTaskData(task)
        DispatchQueue.main.async {
            WatchConnectManager.shared.sendToWatchTask()
        }
    }
    
    func deleteTaskDataIniOS(_ task:EachTask) {
        deleteTaskData(task)
        DispatchQueue.main.async {
            WatchConnectManager.shared.sendToWatchTask()
        }
    }
}

//MARK: - Task add/update/delete (Watch)
extension RealmManager {
    func addTaskDataInWatch(_ task:EachTask) {
        addTaskData(task)
        guard let reloadMainView = reloadMainView else {
            return
        }
        DispatchQueue.main.async {
            reloadMainView(true)
        }
    }
    
    func updateTaskDataInWatch(_ task:EachTask) {
        updateTaskData(task)
        guard let reloadMainView = reloadMainView else {
            return
        }
        DispatchQueue.main.async {
            reloadMainView(true)
        }
    }
    
    func deleteTaskDataInWatch(_ task:EachTask) {
        deleteTaskData(task)
        guard let reloadMainView = reloadMainView else {
            return
        }
        DispatchQueue.main.async {
            reloadMainView(true)
        }
    }
}


//MARK: - Alarm Search
extension RealmManager {
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
    func deleteAllAlarm() {
        openRealm()
        guard let realm = realm else {
            print("realm is nil")
            return
        }
        do {
            try realm.write {
                realm.delete(realm.objects(AlarmInfo.self))
            }
        } catch {
            print("delete AllAlarm Error")
        }
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
        return taskDataBase.first { $0.id == taskId }
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
        
        let foundData = taskDataBase.filter {
            let today = Utils.dateToDateString(date)
            let days = today.split(separator: "-")
            let loadDays = $0.taskDay.split(separator: "-")
            
            if today < $0.taskDay {
                return false
            }
            //당일 추가
            if $0.taskDay == today {
                return true
            }
            
            switch RepeatType(rawValue:$0.repeatType) {
                //매일 반복
            case .EveryDay:
                return $0.isEnd ? $0.taskEndDate >= Utils.dateToDateString(date) : true
                //매주 해당 요일 반복
            case .Eachweek:
                if $0.weekDayList[weekdayIndex] {
                    return $0.isEnd ? $0.taskEndDate >= Utils.dateToDateString(date) : true
                } else {
                    return false
                }
                //매월 해당 일 반복
            case .EachMonthOfOnce:
                if days[2] == loadDays[2] {
                    return $0.isEnd ? $0.taskEndDate >= Utils.dateToDateString(date) : true
                } else {
                    return false
                }
                //매월 해당 주, 해당 요일 반복
            case .EachMonthOfWeek:
                if $0.weekDayList[weekdayIndex] {
                    let week = $0.monthOfWeek
                    if week == 5 {
                        return weekOfMonth == lastWeek
                    } else if week == weekOfMonth {
                        return $0.isEnd ? $0.taskEndDate >= Utils.dateToDateString(date) : true
                    } else {
                        return false
                    }
                } else {
                    return false
                }
                //매년 반복
            case .EachYear:
                if days[1] == loadDays[1] && days[2] == loadDays[2] {
                    return $0.isEnd ? $0.taskEndDate >= Utils.dateToDateString(date) : true
                } else {
                    return false
                }
                //반복 없음
            default:
                return $0.taskDay == Utils.dateToDateString(date)
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
        
        let foundData = taskDataBase.filter {
            if Utils.dateToDateString(lastDate) < $0.taskDay {
                return false
            }
            
            let today = Utils.dateToDateString(date)
            let days = today.split(separator: "-")
            let loadDays = $0.taskDay.split(separator: "-")
            
            switch RepeatType(rawValue:$0.repeatType) {
                //반복 없음
            case .None:
                return days[0] == loadDays[0] && days[1] == loadDays[1] ? true : false
                //매년 반복
            case .EachYear:
                if days[1] == loadDays[1] {
                    return $0.isEnd ? $0.taskEndDate >=  Utils.dateToDateString(firstDate) : true
                } else {
                    return false
                }
            default:
                //그 외 모든 반복
                return $0.isEnd ? $0.taskEndDate >=  Utils.dateToDateString(firstDate): true
            }
        }
        return foundData.map{$0}
    }
}

//MARK: - Category
extension RealmManager {
    func addCategory(_ data:CategoryData) {
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
    }
    
    func loadCategory() -> [CategoryData] {
        guard let realm = realm else {
            print("realm is nil")
            return []
        }
        let categoryList = realm.objects(CategoryData.self)
        return Array(categoryList)
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
        guard let realm = realm else {
            print("realm is nil")
            return false
        }
        let categoryList = realm.objects(CategoryData.self)
        guard let _ = categoryList.first(where: { $0.title == "Default" }) else {
            return false
        }
        return true
    }
}
