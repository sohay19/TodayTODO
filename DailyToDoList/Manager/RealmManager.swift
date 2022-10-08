//
//  RealmManager.swift
//  dailytimetable
//
//  Created by 소하 on 2022/10/01.
//


import Foundation
import RealmSwift
import Realm


class RealmManager {
    private let fileManager = FileManager.default
    private var realm:Realm?
    
    var realmUrl:URL? {
        guard let realm = realm else {
            return nil
        }
        return realm.configuration.fileURL!
    }
}

extension RealmManager {
    func openRealm() {
        do {
            let path = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupId)?.appendingPathComponent("DailyToDoList.realm")
            let config = Realm.Configuration(fileURL: path)
            realm = try Realm(configuration: config)
        } catch {
            print("errer")
        }
    }
    
    func addTaskData(_ data:EachTask) {
        guard let realm = self.realm else {
            print("realm is nil")
            return
        }
        try! realm.write {
            realm.add(data)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func getTaskDataForDay(date:Date) -> LazyFilterSequence<Results<EachTask>>? {
        guard let realm = self.realm else {
            print("realm is nil")
            return nil
        }
        //해당 요일
        let weekdayIndex = Utils.stringToWeekDay(Utils.dateToString(date))
        //해당 주
        let monthOfWeek = Utils.stringToWeekOfMonth(Utils.dateToString(date))
        //마지막 주
        let lastWeek = Utils.getLastWeek(date)
        //전체 DB
        let taskDataBase = realm.objects(EachTask.self)
        
        let foundData = taskDataBase.filter {
            switch $0.repeatType {
                //매일 반복
            case RepeatType.EveryDay.rawValue:
                return $0.isEnd ? $0.taskEndDate >= Utils.dateToString(date) : true
                //매주 해당 요일 반복
            case RepeatType.Eachweek.rawValue:
                if $0.weekDayList[weekdayIndex] {
                    return $0.isEnd ? $0.taskEndDate >= Utils.dateToString(date) : true
                } else {
                    return false
                }
                //매월 해당 일 반복
            case RepeatType.EachMonthOfOnce.rawValue:
                let today = Utils.dateToString(date)
                let days = today.split(separator: "-")
                let loadDays = $0.taskDate.split(separator: "-")
                if days[2] == loadDays[2] {
                    return $0.isEnd ? $0.taskEndDate >= Utils.dateToString(date) : true
                } else {
                    return false
                }
                //매월 해당 주, 해당 요일 반복
            case RepeatType.EachMonthOfWeek.rawValue:
                if $0.weekDayList[weekdayIndex] {
                    let week = $0.monthOfWeek
                    if week == 5 {
                        return monthOfWeek == lastWeek
                    } else if week == monthOfWeek {
                        return $0.isEnd ? $0.taskEndDate >= Utils.dateToString(date) : true
                    } else {
                        return false
                    }
                } else {
                    return false
                }
                //매년 반복
            case RepeatType.EachYear.rawValue:
                let today = Utils.dateToString(date)
                let days = today.split(separator: "-")
                let loadDays = $0.taskDate.split(separator: "-")
                if days[1] == loadDays[1] && days[2] == loadDays[2] {
                    return $0.isEnd ? $0.taskEndDate >= Utils.dateToString(date) : true
                } else {
                    return false
                }
                //반복 없음
            default:
                return $0.taskDate == Utils.dateToString(date)
            }
        }
        
        return foundData
    }
    
    func getTaskDataForMonth(date:Date) -> LazyFilterSequence<Results<EachTask>>? {
        guard let realm = self.realm else {
            print("realm is nil")
            return nil
        }
        //전체 DB
        let taskDataBase = realm.objects(EachTask.self)
        
        let foundData = taskDataBase.filter {
            let today = Utils.dateToString(date)
            let days = today.split(separator: "-")
            let loadDays = $0.taskDate.split(separator: "-")
            
            if days[1] == loadDays[1] {
                switch $0.repeatType {
                    //반복 없음
                case RepeatType.None.rawValue:
                    return days[0] == loadDays[0] ? true : false
                    //이외 모든 반복
                default:
                    return $0.isEnd ? $0.taskEndDate >= Utils.dateToString(date) : true
                }
            } else {
                return false
            }
        }
        
        return foundData
    }
    
    func updateTaskData() {
        
    }
    
    func deleteTaskData() {
        
    }
}

//MARK: - Category
extension RealmManager {
    func addCategory(_ data:CategoryData) {
        guard let realm = self.realm else {
            print("realm is nil")
            return
        }
        try! realm.write {
            realm.add(data)
        }
    }
    
    func loadCategory() -> Results<CategoryData>? {
        guard let realm = self.realm else {
            print("realm is nil")
            return nil
        }
        return realm.objects(CategoryData.self)
    }
}
