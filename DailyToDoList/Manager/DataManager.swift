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
        pushManager.deleteAllPush()
        RealmManager.shared.deleteAllAlarm()
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
    func removeBadgeCnt() {
        pushManager.removeBadgeCnt()
    }
}
