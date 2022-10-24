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
    
    private var notificationToken:RLMNotificationToken = RLMNotificationToken.init()
}

//MARK: - Func
extension DataManager {
    func deleteAllFile() {
        deleteiCloudBackupFile()
        RealmManager.shared.deleteOriginFile()
    }
}

//MARK: - Realm
extension DataManager {
    //
    func openRealm() {
        guard let url = RealmManager.shared.openRealm() else {
            return
        }
        cloudManager.realmUrl = url
        print("realmUrl = \(url)")
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
