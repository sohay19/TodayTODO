//
//  DataManager.swift
//  dailytimetable
//
//  Created by 소하 on 2022/09/05.
//
import UIKit
import Foundation
import RealmSwift
import Realm
import FirebaseAuth

class DataManager {
    static let shared = DataManager()
    private init() { }
    
    private let cloudManager = CloudManager()
    private let realmManager = RealmManager()
    
    private var notificationToken:RLMNotificationToken = RLMNotificationToken.init()
}

//MARK: - Func
extension DataManager {
    func deleteAllFile() {
        deleteiCloudBackupFile()
        deleteOriginRealmFile()
    }
    //
    func getUUID() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
}

//MARK: - Realm
extension DataManager {
    //
    func openRealm() {
        guard let url = realmManager.openRealm() else {
            return
        }
        cloudManager.realmUrl = url
        print("realmUrl = \(url)")
    }
    //
    func addTaskData(_ data:EachTask) {
        realmManager.addTaskData(data)
    }
    func updateTaskData(_ task:EachTask) {
        realmManager.updateTaskData(task)
    }
    func deleteTaskData(_ task:EachTask) {
        realmManager.deleteTaskData(task)
    }
    //search
    func getTaskDataForDay(date:Date) -> LazyFilterSequence<Results<EachTask>>? {
        return realmManager.getTaskDataForDay(date: date)
    }
    func getTaskDataForMonth(date:Date) -> LazyFilterSequence<Results<EachTask>>? {
        return realmManager.getTaskDataForMonth(date: date)
    }
    //category
    func addCategory(_ data:CategoryData) {
        realmManager.addCategory(data)
    }
    func loadCategory() -> Results<CategoryData>? {
        return realmManager.loadCategory()
    }
    func getCategoryColor(_ categoryName:String) -> UIColor {
        return realmManager.getCategoryColor(categoryName)
    }
    //
    func findAlarmIdList(_ taskId:String) -> [String] {
        guard let idList = realmManager.getAlarmIdList(taskId) else {
            return []
        }
        return idList
    }
    //
    private func deleteOriginRealmFile() {
        realmManager.deleteOriginFile()
    }
}

//MARK: - iCloud
extension DataManager {
    //
    func updateCloud(label:UILabel) {
        cloudManager.updateDate(label)
    }
    //
    func iCloudBackup(_ vc:UIViewController) {
        cloudManager.backUpFile(vc)
    }
    //
    func iCloudLoadFile(_ vc:UIViewController) {
        cloudManager.loadBackupFile(vc)
    }
    //
    func deleteiCloudBackupFile() {
        cloudManager.deleteBackupFile()
    }
}

//MARK: - Push
extension DataManager {
    private func getBadgeCnt() -> Int {
        return UserDefaults.shared.integer(forKey: BadgeCountKey)
    }
    
    func addBadgeCnt() -> Int {
        let badgeCnt = getBadgeCnt() + 1
        UserDefaults.shared.set(badgeCnt, forKey: BadgeCountKey)
        
        return badgeCnt
    }
    
    func removeBadgeCnt() {
        UserDefaults.shared.set(0, forKey: BadgeCountKey)
    }
}
