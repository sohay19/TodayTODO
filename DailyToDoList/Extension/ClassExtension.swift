//
//  ClassExtension.swift
//  dailytimetable
//
//  Created by 소하 on 2022/08/19.
//


import Foundation
import UIKit

extension UserDefaults {
    static var shared: UserDefaults {
        let appGroupId = appGroupId
        return UserDefaults(suiteName: appGroupId)!
    }
}
