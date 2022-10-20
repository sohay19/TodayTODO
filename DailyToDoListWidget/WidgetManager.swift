//
//  WidgetManager.swift
//  dailytimetable
//
//  Created by 소하 on 2022/09/28.
//

import Foundation
import RealmSwift
import Realm


class WidgetManager {
    static let shared = WidgetManager()
    private init() {
        openRealm()
    }
    
    private let realmManager = RealmManager()
}

//MARK: - Realm
extension WidgetManager {
    func openRealm() {
        let _ = realmManager.openRealm()
    }

    func getTaskDataForDay(date:Date) -> LazyFilterSequence<Results<EachTask>>? {
        return realmManager.getTaskDataForDay(date: date)
    }

    func getTaskDataForMonth(date:Date) -> LazyFilterSequence<Results<EachTask>>? {
        return realmManager.getTaskDataForMonth(date: date)
    }
}
