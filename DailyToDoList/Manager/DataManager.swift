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
    
    private let pushManager = PushManager()
    private let cloudManager = CloudManager()
    private let firebaseManager = FirebaseManager()
    
    private var notificationToken:RLMNotificationToken = RLMNotificationToken.init()
    
    private var tmpNick = ""
}

//MARK: - Realm
extension DataManager {
    func openRealm() {
        cloudManager.realmManager.openRealm()
    }
    
    func deleteRealmFile() {
        cloudManager.deleteOriginFile()
    }
    
    func addTaskData(_ data:EachTask) {
        cloudManager.realmManager.addTaskData(data)
        if data.isAlarm {
            pushManager.setNotification(data)            
        }
    }
    
    func getTaskDataForDay(date:Date) -> LazyFilterSequence<Results<EachTask>>? {
        return cloudManager.realmManager.getTaskDataForDay(date: date)
    }
    
    func getTaskDataForMonth(date:Date) -> LazyFilterSequence<Results<EachTask>>? {
        return cloudManager.realmManager.getTaskDataForMonth(date: date)
    }
    
    func updateTaskData(_ task:EachTask) {
        cloudManager.realmManager.updateTaskData(task)
    }
    
    func deleteTaskData(_ task:EachTask) {
        cloudManager.realmManager.deleteTaskData(task)
    }
    
    func addCategory(_ data:CategoryData) {
        cloudManager.realmManager.addCategory(data)
    }
    
    func loadCategory() -> Results<CategoryData>? {
        return cloudManager.realmManager.loadCategory()
    }
}

//MARK: - Firebase
extension DataManager {
    func addUserDataInFirebase(_ user:UserData) {
        firebaseManager.addData(user)
    }
    
    func checkNickName(_ nick:String, compelete: @escaping (Bool) -> Void) {
        return firebaseManager.checkNick(nick, compelete: compelete)
    }
    
    func checkUID(_ uid:String, compelete: @escaping (Bool) -> Void) {
        firebaseManager.checkUID(uid, compelete: compelete)
    }
    
    func makeSHA() -> String {
        return firebaseManager.shaNonce()
    }
    
    func getNonce() -> String {
        return firebaseManager.getNonce()
    }
    
    func getAuth() -> FirebaseAuth.User? {
        guard let auth = firebaseManager.authUser else {
            return nil
        }
        return auth
    }
    
    func loadFirebaseUserData(_ complete: @escaping (UserData) -> Void) {
        return firebaseManager.findData(complete)
    }
}

//MARK: - iCloud
extension DataManager {
    func updateCloud(label:UILabel) {
        cloudManager.updateDate(label)
    }
    
    func iCloudBackup(_ vc:UIViewController) {
        cloudManager.backUpFile(vc)
    }
    
    func iCloudLoadFile(_ vc:UIViewController) {
        cloudManager.loadBackupFile(vc)
    }
    
    func deleteiCloudBackupFile() {
        cloudManager.deleteBackupFile()
    }
}

//MARK: - UserData 관련 기능
extension DataManager {
    func modifyNickName(_ nick:String) {
        let myData = loadUserData()
        //Firebase 수정
        firebaseManager.updateData(uid: myData.uid, type: UserDataType.NickName, data: nick)
        //UserDefaults 수정
        setUserNickName(nick)
    }
    
    func deleteAccount(_ vc: UIViewController) {
        firebaseManager.deleteAccount(vc)
        cloudManager.deleteFileAll()
    }
    
    func logout() {
        setAutoLogin(false)
    }
    
    func getAuto() -> Bool {
        return UserDefaults.shared.bool(forKey: AutoLoginKey)
    }
    
    func getLoginType() -> LoginType {
        guard let type =  UserDefaults.shared.string(forKey: LoginTypeKey) else {
            return LoginType.None
        }
        guard let loginType = LoginType(rawValue: type) else {
            return LoginType.None
        }
        return loginType
    }
    
    func setUserData(_ uid:String, _ email:String, _ name:String, _ type:LoginType)
    {
        UserDefaults.shared.set(uid, forKey: UserUidKey)
        UserDefaults.shared.set(email, forKey: UserEmailKey)
        UserDefaults.shared.set(name, forKey: UserNameKey)
        //닉네임 중복 여부
        tmpNick = "User\(Int.random(in: 1000...9999))"
        randomNickName()
        
        UserDefaults.shared.set(tmpNick, forKey: UserNickKey)
        UserDefaults.shared.set(type.rawValue, forKey: LoginTypeKey)
    }
    
    func randomNickName() {
        DataManager.shared.checkNickName(tmpNick) { isExist in
            if isExist {
                self.tmpNick = "User\(Int.random(in: 1000...9999))"
                self.randomNickName()
            }
        }
    }
    
    func setUserNickName(_ nick:String) {
        UserDefaults.shared.set(nick, forKey: UserNickKey)
    }
    
    func removeUserData() {
        UserDefaults.shared.removeObject(forKey: UserUidKey)
        UserDefaults.shared.removeObject(forKey: UserEmailKey)
        UserDefaults.shared.removeObject(forKey: UserNameKey)
        UserDefaults.shared.removeObject(forKey: UserNickKey)
        UserDefaults.shared.removeObject(forKey: LoginTypeKey)
    }
    
    func setAutoLogin(_ isAuto:Bool) {
        UserDefaults.shared.set(isAuto, forKey: AutoLoginKey)
    }
    
    func loadUserData() -> UserData {
        let uid = UserDefaults.shared.string(forKey: UserUidKey)!
        let email = UserDefaults.shared.string(forKey: UserEmailKey)!
        let name = UserDefaults.shared.string(forKey: UserNameKey)!
        let nick = UserDefaults.shared.string(forKey: UserNickKey)!
        let type = UserDefaults.shared.string(forKey: LoginTypeKey)!
        
        return UserData(uid: uid, email: email, name: name, nick: nick, type: type)
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
