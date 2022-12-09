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
import UserNotifications


class RealmManager {
    private let fileManager = FileManager.default
    //
    private var realmUrl:URL?
    private var realm:Realm?
    private let realmDir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId)?.appendingPathComponent(realmPath, isDirectory: true)
    //
    private var watchUrl:URL?
    private var watchRealm:Realm?
    private let watchDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(realmPath, conformingTo: .directory)
}

//MARK: - Main
extension RealmManager {
    func openRealm() {
#if os(iOS)
        guard let realmDir = realmDir else {
            print("Path 없음")
            return
        }
#else
        let realmDir = watchDir
#endif
        if !fileManager.fileExists(atPath: realmDir.path) {
            fileManager.createDir(realmDir) { error in
                print("create error = \(error)")
            }
        }
        do {
            let path = realmDir.appendingPathComponent(realmFile)
            let config = Realm.Configuration(fileURL: path)
#if os(iOS)
            realm = try Realm(configuration: config)
            guard let realm = realm else {
                return
            }
            realmUrl = realm.configuration.fileURL
#else
            watchRealm = try Realm(configuration: config)
            guard let realm = watchRealm else {
                return
            }
            watchUrl = realm.configuration.fileURL
#endif
            if !haveDefault() {
                let newList:[Float] = Utils.FloatFromRGB(rgbValue: 0x000000, alpha: 1)
                let newCategory = CategoryData(DefaultCategory, newList)
                addCategory(newCategory)
            } else {
                DataManager.shared.reloadCategoryOrder()
            }
        } catch let error {
            print("Realm Open Error = \(error)")
        }
    }
    //
    func deleteOriginFile() {
        openRealm()
#if os(iOS)
        guard let realmDir = realmDir else {
            print("realmDir is nil")
            return
        }
#else
        let realmDir = watchDir
#endif
        fileManager.deleteDir(realmDir, nil)
    }
    //
    func getRealmURL() -> URL? {
#if os(iOS)
        return realmUrl
#else
        return watchUrl
#endif
    }
}
extension RealmManager {
    //MARK: - Task
    func addTask(_ task:EachTask) {
        openRealm()
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return
        }
#endif
        do {
            try realm.write {
                realm.add(task)
            }
        } catch {
            print("Realm add Error")
        }
    }
    // updateTask
    func updateTask(_ task:EachTask) {
        openRealm()
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return
        }
#endif
        do {
            try realm.write {
                realm.add(task, update: .modified)
            }
        } catch {
            print("Realm update Error")
        }
    }
    // deleteTask
    func deleteTask(_ task:EachTask) {
        openRealm()
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return
        }
#endif
        do {
            try realm.write {
                realm.delete(task)
            }
        } catch {
            print("Realm delete Error")
        }
    }
}


//MARK: - Alarm
extension RealmManager {
    //alarmInfo ADD
    func addAlarm(_ idList:[String], _ alarmInfo:AlarmInfo) {
        openRealm()
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return
        }
#endif
        do {
            try realm.write {
                realm.add(alarmInfo)
            }
        } catch {
            print("Realm add Error")
        }
    }
    //alarmInfo Update
    func updateAlarm(_ taskId:String, _ removeId:String) {
        openRealm()
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return
        }
#endif
        do {
            guard let alarmInfo = getAlarmInfo(taskId) else {
                return
            }
            var idList = alarmInfo.getIdList()
            if let index = idList.firstIndex(of: removeId) {
                idList.remove(at: index)
            }
            let newInfo = AlarmInfo(alarmInfo.taskId, idList, alarmInfo.alarmTime)
            try realm.write {
                realm.add(newInfo, update: .modified)
            }
        } catch {
            print("Realm add Error")
        }
    }
    func updateAlarm(_ alarmInfo:AlarmInfo) {
        openRealm()
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return
        }
#endif
        do {
            try realm.write {
                realm.add(alarmInfo, update: .modified)
            }
        } catch {
            print("Realm add Error")
        }
    }
    //alarmInfo 선택 삭제
    func deleteAlarm(_ taskId:String) {
        openRealm()
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return
        }
#endif
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
    func deleteAlarm(_ alarmInfo:AlarmInfo) {
        openRealm()
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return
        }
#endif
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
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return
        }
#endif
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
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return []
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return []
        }
#endif
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
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return nil
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return nil
        }
#endif
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
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return []
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return []
        }
#endif
        return realm.objects(AlarmInfo.self).map{$0}
    }
}

//MARK: - Task Search
extension RealmManager {
    func getTaskAllData() -> [EachTask] {
        openRealm()
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return []
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return []
        }
#endif
        //전체 DB
        let taskDataBase = realm.objects(EachTask.self)
        return taskDataBase.map{$0}
    }
    func getTaskData(_ taskId:String) -> EachTask? {
        openRealm()
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return nil
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return nil
        }
#endif
        //전체 DB
        let taskDataBase = realm.objects(EachTask.self)
        return taskDataBase.first { $0.taskId == taskId }
    }
    //
    func getTaskDataForDay(date:Date) -> [EachTask] {
        openRealm()
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return []
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return []
        }
#endif
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
            let todayList = today.split(separator: "-")
            let taskDayList = task.taskDay.split(separator: "-")
            
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
                if todayList[2] == taskDayList[2] {
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
                if todayList[1] == taskDayList[1] && todayList[2] == taskDayList[2] {
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
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return []
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return []
        }
#endif
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
            let todayList = today.split(separator: "-")
            let taskDayList = task.taskDay.split(separator: "-")
            //
            let option = task.optionData ?? OptionData()
            let isEnd = option.isEnd
            let taskEndDate = option.taskEndDate
            //
            switch RepeatType(rawValue:task.repeatType) {
                //반복 없음 (연,월)
            case .None:
                return todayList[0] == taskDayList[0] && todayList[1] == taskDayList[1] ? true : false
                //매년 반복 (월)
            case .EachYear:
                if todayList[1] == taskDayList[1] {
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
    //
    func getTaskForCategory(_ category:String) -> [EachTask] {
        openRealm()
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return []
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return []
        }
#endif
        let taskDataBase = realm.objects(EachTask.self)
        let foundData = taskDataBase.filter{ $0.category == category }
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
            var array = DataManager.shared.getCategoryOrder()
            if let _ = array.first(where: {$0 == data.title}) {
                return
            }
            array.append(data.title)
            DataManager.shared.setCategoryOrder(array)
            try realm.write {
                realm.add(data)
            }
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
    //
    func updateCategory(_ data:CategoryData) {
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return
        }
#endif
        do {
            try realm.write {
                realm.add(data, update: .modified)
            }
        } catch {
            print("category updadte Error")
        }
    }
    //
    func loadCategory() -> [CategoryData] {
        openRealm()
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return []
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return []
        }
#endif
        let categoryList = realm.objects(CategoryData.self)
        return Array(categoryList)
    }
    func getCategory(_ title:String) -> CategoryData? {
        openRealm()
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return nil
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return nil
        }
#endif
        let categoryList = realm.objects(CategoryData.self)
        return categoryList.first(where: {$0.title == title})
    }
    //
    func deleteCategory(_ category:String) {
        openRealm()
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return
        }
#endif
        do {
            let data = realm.objects(CategoryData.self)
            guard let findCategory = data.first(where: {$0.title == category}) else {
                return
            }
            try realm.write {
                realm.delete(findCategory)
            }
        } catch {
            print("Realm add Error")
        }
    }
    //
    func deleteCategory(_ category:CategoryData) {
        openRealm()
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return
        }
#endif
        do {
            try realm.write {
                realm.delete(category)
            }
        } catch {
            print("Realm add Error")
        }
    }
    //
    func deleteAllCategory() {
        openRealm()
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return
        }
#endif
        do {
            let data = realm.objects(CategoryData.self)
            try realm.write {
                realm.delete(data)
            }
        } catch {
            print("Realm add Error")
        }
    }
    //
    private func haveDefault() -> Bool {
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return false
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return false
        }
#endif
        let categoryList = realm.objects(CategoryData.self)
        guard let _ = categoryList.first(where: { $0.title == DefaultCategory }) else {
            return false
        }
        return true
    }
    //
    func getCategoryColor(_ category:String) -> UIColor {
        let categoryList = loadCategory()
        if let target = categoryList.first(where: {$0.title == category}){
            let color = Utils.getColor(target.colorList)
            return color
        } else {
            return .black
        }
    }
    //
    func setCategoryOrder(_ data:CategoryOrderData) {
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return
        }
#endif
        do {
            try realm.write {
                realm.add(data, update: .modified)
            }
        } catch {
            print("Realm add Error")
        }
    }
    //
    func getCategoryOrder() -> [String] {
#if os(iOS)
        guard let realm = realm else {
            print("realm is nil")
            return []
        }
#else
        guard let realm = watchRealm else {
            print("watchRealm is nil")
            return []
        }
#endif
        let categoryOrder = realm.objects(CategoryOrderData.self)
        guard let first = categoryOrder.first else {
            return []
        }
        return first.getCategoryOrder()
    }
}
