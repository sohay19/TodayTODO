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
import RealmSwift
import Realm


class DataManager {
    static let shared = DataManager()
    private init() { }
    
    private let cloudManager = CloudManager()
    private let pushManager = PushManager()
}

//MARK: - Func
extension DataManager {
    func deleteAllFile() {
        deleteiCloudAllBackupFile()
        RealmManager.shared.deleteOriginFile()
        //
        DataManager.shared.deleteAllAlarmPush()
    }
}

//MARK: - iCloud
extension DataManager {
    //
    func getAllBackupFile() -> [(String, URL)] {
        return cloudManager.getAllBackupFile()
    }
    //
    func updateCloud(label:UILabel) {
        cloudManager.updateDate(label)
    }
    //
    func iCloudBackup(_ vc:UIViewController) {
        cloudManager.backUpFile(vc)
    }
    //
    func iCloudLoadFile(_ vc:UIViewController, _ url:URL) {
        cloudManager.loadBackupFile(vc, url)
    }
    func iCloudLoadRecentlyFile(_ vc:UIViewController) {
        cloudManager.loadRecentlyBackupFile(vc)
    }
    //
    func deleteiCloudBackupFile(_ url:URL) {
        cloudManager.deleteBackupFile(url)
    }
    func deleteiCloudAllBackupFile() {
        cloudManager.deleteAllBackupFile()
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
    //alarmInfo, push 선택 삭제
    func deleteAlarmPush(_ taskId:String, _ id:String) {
        let idList = RealmManager.shared.getAlarmIdList(taskId)
        //alarminfo가 없을 때
        if idList.isEmpty {
            deletePush(id)
            return
        }
        pushManager.deletePush(idList)
        // alarmInfo 삭제
        RealmManager.shared.deleteAlarm(taskId)
    }
    //alarmInfo, push 모두 삭제
    func deleteAllAlarmPush() {
        pushManager.deleteAllPush()
        // alarmInfo 모두 삭제
        RealmManager.shared.deleteAllAlarm()
    }
    //
    func removeBadgeCnt() {
        pushManager.removeBadgeCnt()
    }
}
