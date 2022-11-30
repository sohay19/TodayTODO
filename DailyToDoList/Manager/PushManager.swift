//
//  PushManager.swift
//  dailytimetable
//
//  Created by 소하 on 2022/09/17.
//

import Foundation
import UserNotifications
import UIKit

class PushManager {
    private let notiCenter = UNUserNotificationCenter.current()
}

//MARK: - Basic
extension PushManager {
    //푸쉬콘텐츠 내용 설정
    private func setNotiContent(_ data:EachTask, _ id:String) -> UNMutableNotificationContent {
        let notiContent = UNMutableNotificationContent()
        //카테고리
        notiContent.categoryIdentifier = "DailyTODO"
        //제목내용
        notiContent.title = data.title
        notiContent.body = data.memo
        //push 메세지에 담긴 데이터
        let option = data.optionData ?? OptionData()
        notiContent.userInfo = [pushTypeKey:PushType.Alert.rawValue, endDateKey:option.taskEndDate, idKey:data.taskId, repeatTypeKey:data.repeatType, alarmTimeKey:option.alarmTime]
        //알림음 설정
        notiContent.sound = UNNotificationSound.default
        //뱃지 표시
        notiContent.badge = (addBadgeCnt()) as NSNumber
        //썸네일
        do {
            //            let imageUrl = Bundle.main.url(forResource: "Tulips", withExtension: "jpg")
            //            let attach = try UNNotificationAttachment(identifier: "", url: imageUrl!, options: nil)
            //            notiPush.attachments.append(attach)
        } catch {
            print(error)
        }
        
        return notiContent
    }
    //Noti 생성
    func addNotification(_ data:EachTask) -> [String] {
        var idList:[String] = []
        var index = 0
        //
        guard let option = data.optionData else { return [] }
        //기본 알람 시간 세팅
        let time = option.alarmTime.components(separatedBy: ":").map{Int($0)!}
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.hour = time[0]
        dateComponents.minute = time[1]
        //
        let startDate = Utils.dateStringToDate(data.taskDay)!
        let endDate = Utils.dateStringToDate(option.taskEndDate)!
        var nextDate = startDate
        switch RepeatType(rawValue: data.repeatType) {
        case .EveryDay:
            if option.isEnd {
                while endDate >= nextDate {
                    guard let newDate = Calendar.current.nextDate(after: nextDate, matching: dateComponents, matchingPolicy: .nextTime) else { break }
                    if nextDate == newDate {
                        break
                    }
                    nextDate = newDate
                    let date = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: nextDate)
                    let id = addNotiForCenter(data, index, date)
                    idList.append(id)
                    index += 1
                }
            }
        case .Eachweek:
            if option.isEnd {
                for (i, week) in option.getWeekDayList().enumerated() {
                    if week {
                        dateComponents.weekday = i+1
                        while endDate >= nextDate {
                            guard let newDate = Calendar.current.nextDate(after: nextDate, matching: dateComponents, matchingPolicy: .nextTime) else { break }
                            if nextDate == newDate {
                                break
                            }
                            nextDate = newDate
                            let date = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: nextDate)
                            let id = addNotiForCenter(data, index, date)
                            idList.append(id)
                            index += 1
                        }
                    }
                }
            }
        case .EachOnceOfMonth:
            if option.isEnd {
                dateComponents.day = Utils.getDay(data.taskDay)
                while endDate >= nextDate {
                    guard let newDate = Calendar.current.nextDate(after: nextDate, matching: dateComponents, matchingPolicy: .nextTime) else { break }
                    if nextDate == newDate {
                        break
                    }
                    nextDate = newDate
                    let date = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: nextDate)
                    let id = addNotiForCenter(data, index, date)
                    idList.append(id)
                    index += 1
                }
            }
        case .EachWeekOfMonth:
            if option.isEnd {
                let weekOfMonth = option.weekOfMonth
                if weekOfMonth == -1 {
                    dateComponents.weekdayOrdinal = weekOfMonth
                } else {
                    dateComponents.weekOfMonth = weekOfMonth
                }
                for (i, week) in option.getWeekDayList().enumerated() {
                    if week {
                        dateComponents.weekday = i+1
                        while endDate >= nextDate {
                            guard let newDate = Calendar.current.nextDate(after: nextDate, matching: dateComponents, matchingPolicy: .nextTime) else { break }
                            if nextDate == newDate {
                                break
                            }
                            nextDate = newDate
                            let date = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: nextDate)
                            let id = addNotiForCenter(data, index, date)
                            idList.append(id)
                            index += 1
                        }
                    }
                }
            }
        case .EachYear:
            if option.isEnd {
                dateComponents.month = Utils.getMonth(data.taskDay)
                dateComponents.day = Utils.getDay(data.taskDay)
                while endDate >= nextDate {
                    guard let newDate = Calendar.current.nextDate(after: nextDate, matching: dateComponents, matchingPolicy: .nextTime) else { break }
                    if nextDate == newDate {
                        break
                    }
                    nextDate = newDate
                    let date = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: nextDate)
                    let id = addNotiForCenter(data, index, date)
                    idList.append(id)
                    index += 1
                }
            }
        default:
            break
        }
        return idList
    }
}

//MARK: - Add
extension PushManager {
    private func addNotiForCenter(_ data:EachTask, _ idIndex:Int, _ dateComponents:DateComponents) -> String {
        //id 및 내용 설정
        let id = "\(data.taskId)_\(idIndex)"
        let notiContent = setNotiContent(data, id)
        //trigger 세팅
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: notiContent, trigger: trigger)
        //
        notiCenter.add(request) { error in
            if let error = error {
                print("Noti Add Error = \(error)")
            }
        }
        return id
    }
}

//MARK: - update/delete
extension PushManager {
    //
    func updatePush(_ idList:[String], _ task:EachTask) -> [String] {
        deletePush(idList)
        return addNotification(task)
    }
    //
    func deletePush(_ idList:[String]) {
        notiCenter.removePendingNotificationRequests(withIdentifiers: idList)
    }
    //모든 푸쉬 삭제
    func deleteAllPush() {
        notiCenter.removeAllPendingNotificationRequests()
        print("Delete All Noti")
    }
}

//MARK: - Badge
extension PushManager {
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


//MARK: - Etc Event
extension PushManager {
    //
    func getAllRequest(_ complete: @escaping ([UNNotificationRequest]) -> Void) {
        notiCenter.getPendingNotificationRequests(completionHandler: complete)
    }
}
