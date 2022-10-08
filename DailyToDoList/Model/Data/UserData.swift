//
//  UserData.swift
//  dailytimetable
//
//  Created by 소하 on 2022/08/18.
//
//유저 정보

import Foundation

class UserData {
    var uid:String
    var email:String
    var name:String
    var nickName:String
    var loginType:String
      
    
    init() {
        self.uid = ""
        self.email = ""
        self.name = ""
        self.nickName = ""
        self.loginType = LoginType.None.rawValue
    }
    
    convenience init(uid:String, email:String, name:String, nick:String, type:String) {
        self.init()
        self.uid = uid
        self.email = email
        self.name = name
        self.nickName = nick
        self.loginType = type
    }
}
