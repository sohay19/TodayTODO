//
//  FirebaseManager.swift
//  dailytimetable
//
//  Created by 소하 on 2022/09/21.
//

import Foundation
import FirebaseDatabase
import FirebaseCore
import FirebaseAuth
import CryptoKit


class FirebaseManager {
    private var database = Database.database().reference()
    
    private var currentNonce = ""
    var authUser:User? {
        get {
            guard let auth = Auth.auth().currentUser else {
                return nil
            }
            return auth
        }
    }
}

//MARK: - 데이터 관리 함수
extension FirebaseManager {
    func addData(_ data:UserData) {
        let value = [UserDataType.Email.rawValue:data.email, UserDataType.Name.rawValue:data.name, UserDataType.NickName.rawValue:data.nickName, UserDataType.LoginType.rawValue:data.loginType]
        database.child(UserDataType.None.rawValue).child(data.uid).setValue(value)
        //uuid 중복확인을 위해
        database.child(UserDataType.Uid.rawValue).child(data.uid).setValue(data.loginType)
        //닉네임 중복확인을 위해
        database.child(UserDataType.NickName.rawValue).child(data.nickName).setValue(data.uid)
    }
    
    func updateData(uid: String, type:UserDataType, data:String) {
        switch type {
        case .NickName:
            //userdata 변경
            database.child(UserDataType.None.rawValue).child(uid).child(type.rawValue).setValue(data)
            //기존 닉네임 삭제 후, 추가
            let userData = DataManager.shared.loadUserData()
            let oldNick = userData.nickName
            database.child(UserDataType.NickName.rawValue).child(oldNick).removeValue()
            database.child(UserDataType.NickName.rawValue).child(data).setValue(uid)
        default:
            return
        }
        
    }
    
    func removeData() {
        let userData = DataManager.shared.loadUserData()
        
        database.child(UserDataType.None.rawValue).child(userData.uid).removeValue()
        database.child(UserDataType.Uid.rawValue).child(userData.uid).removeValue()
        database.child(UserDataType.NickName.rawValue).child(userData.nickName).removeValue()
    }
    
    func findData(_ complete: @escaping (UserData) -> Void) {
        guard let auth = Auth.auth().currentUser else {
            return
        }
        
        database.child(UserDataType.None.rawValue).child(auth.uid).observeSingleEvent(of: .value) { snapshot in
            let uid = auth.uid
            var email = ""
            var name = ""
            var nickName = ""
            var loginType = ""
            
            for child in snapshot.children {
                let dataSnapshot = child as? DataSnapshot
                let key = dataSnapshot?.key as? String ?? ""
                let value = dataSnapshot?.value as? String ?? ""
                
                switch key {
                case UserDataType.Email.rawValue:
                    email = value
                case UserDataType.Name.rawValue:
                    name = value
                case UserDataType.NickName.rawValue:
                    nickName = value
                case UserDataType.LoginType.rawValue:
                    loginType = value
                default:
                    break
                }
            }
            let userData = UserData(uid: uid, email: email, name: name, nick: nickName, type: loginType)
            complete(userData)
        }
    }
}

//MARK: - 기타 기능
extension FirebaseManager {    
    func checkNick(_ nick:String, compelete: @escaping (Bool) -> Void) {
        database.child(UserDataType.NickName.rawValue).child(nick).observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? String ?? ""
            var isExist = false
            
            if !value.isEmpty {
                isExist = true
            }
            compelete(isExist)
        }
    }
    
    func checkUID(_ uid:String, compelete: @escaping (Bool) -> Void) {
        database.child(UserDataType.Uid.rawValue).child(uid).observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? String ?? ""
            var isExist = false
            
            if let _ = LoginType(rawValue: value) {
                isExist = true
            }
            compelete(isExist)
        }
    }
    
    func deleteAccount(_ vc:UIViewController) {
        //데이터 지우기
        self.removeData()
        //탈퇴
        let user = Auth.auth().currentUser
        user?.delete { error in
            if let _ = error {
                PopupManager.shared.openOkAlert(vc, title: "알림", msg: "탈퇴 중 문제가 발생했습니다.\n다시 시도해주세요")
            }
        }
    }
}

//MARK: - Apple Login을 위한 추가 함수
extension FirebaseManager {
    func shaNonce() -> String {
        currentNonce = randomNonce()
        return sha256(currentNonce)
    }
    
    func getNonce() -> String{
        return currentNonce
    }
    
    private func randomNonce(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
