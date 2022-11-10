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
        notiContent.userInfo = [pushTypeKey:PushType.Alert.rawValue, endDateKey:data.taskEndDate, idKey:data.id, repeatTypeKey:data.repeatType, alarmTimeKey:data.alarmTime]
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
    //기본 알람 시간 세팅
    private func getDateComponents(_ data:EachTask) -> DateComponents {
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        //알람 시간 설정
        let time = data.alarmTime.split(separator: ":")
        let h = Int(time[0])
        let m = Int(time[1])
        dateComponents.hour = h
        dateComponents.minute = m
        return dateComponents
    }
    //Noti 생성
    func addNotification(_ data:EachTask) -> [String] {
        //
        var idList:[String] = []
        var index = 0
        //반복 여부 체크
        switch RepeatType.init(rawValue: data.repeatType) {
        case .EveryDay:
            idList.append(setRepeatDayNoti(data, index))
        case .Eachweek:
            //
            for i in 0..<data.weekDayList.count {
                if data.weekDayList[i] {
                    index += 1
                    idList.append(setRepeatWeekNoti(data, index))
                }
            }
        case .EachOnceOfMonth:
            idList.append(setRepeatMonthOfOnceNoti(data, index))
        case .EachWeekOfMonth:
            //
            for i in 0..<data.weekDayList.count {
                if data.weekDayList[i] {
                    index += 1
                    idList.append(setRepeatWeekOfMonthNoti(data, index))
                }
            }
        case .EachYear:
            idList.append(setRepeatYearNoti(data, index))
        default:
            idList.append(setNotRepeatNoti(data, index))
        }
        return idList
    }
}

//MARK: - Add
extension PushManager {
    //반복없음
    private func setNotRepeatNoti(_ data:EachTask, _ idIndex:Int) -> String {
        //콘텐츠 설정
        let id = "\(data.id)_\(idIndex)"
        let notiContent = setNotiContent(data, id)
        //push 날짜 설정
        var dateComponents = getDateComponents(data)
        let dateArr = data.taskDay.split(separator: "-")
        dateComponents.year = Int(dateArr[0])
        dateComponents.month = Int(dateArr[1])
        dateComponents.day = Int(dateArr[2])
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
    //매일 반복
    private func setRepeatDayNoti(_ data:EachTask, _ idIndex:Int) -> String {
        //콘텐츠 설정
        let id = "\(data.id)_\(idIndex)"
        let notiContent = setNotiContent(data, id)
        //push 날짜 설정
        let dateComponents = getDateComponents(data)
        //trigger 세팅
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: notiContent, trigger: trigger)
        //
        notiCenter.add(request) { error in
            if let error = error {
                print("Noti Add Error = \(error)")
            }
        }
        return id
    }
    //주 n회 반복
    private func setRepeatWeekNoti(_ data:EachTask, _ weekDay:Int) -> String {
        //콘텐츠 설정
        let id = "\(data.id)_\(weekDay)"
        let notiContent = setNotiContent(data, id)
        //push 날짜 설정
        var dateComponents = getDateComponents(data)
        dateComponents.weekday = weekDay+1
        //trigger 세팅
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: notiContent, trigger: trigger)
        //
        notiCenter.add(request) { error in
            if let error = error {
                print("Noti Add Error = \(error)")
            }
        }
        return id
    }
    //월 1회 반복
    private func setRepeatMonthOfOnceNoti(_ data:EachTask, _ idIndex:Int) -> String {
        //콘텐츠 설정
        let id = "\(data.id)_\(idIndex)"
        let notiContent = setNotiContent(data, id)
        //push 날짜 설정
        var dateComponents = getDateComponents(data)
        let dateArr = data.taskDay.split(separator: "-")
        dateComponents.day = Int(dateArr[2])
        //trigger 세팅
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: notiContent, trigger: trigger)
        //
        notiCenter.add(request) { error in
            if let error = error {
                print("Noti Add Error = \(error)")
            }
        }
        return id
    }
    //월 n회 반복
    private func setRepeatWeekOfMonthNoti(_ data:EachTask, _ weekDay:Int) -> String {
        //콘텐츠 설정
        let id = "\(data.id)_\(weekDay)"
        let notiContent = setNotiContent(data, id)
        //push 날짜 설정
        var dateComponents = getDateComponents(data)
        dateComponents.weekday = weekDay+1
        if data.weekOfMonth == -1 {
            dateComponents.weekdayOrdinal = data.weekOfMonth
        } else {
            dateComponents.weekOfMonth = data.weekOfMonth
        }
        //trigger 세팅
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: notiContent, trigger: trigger)
        //
        notiCenter.add(request) { error in
            if let error = error {
                print("Noti Add Error = \(error)")
            }
        }
        return id
    }
    //연 1회 반복
    private func setRepeatYearNoti(_ data:EachTask, _ idIndex:Int) -> String {
        //콘텐츠 설정
        let id = "\(data.id)_\(idIndex)"
        let notiContent = setNotiContent(data, id)
        //push 날짜 설정
        var dateComponents = getDateComponents(data)
        let dateArr = data.taskDay.split(separator: "-")
        dateComponents.month = Int(dateArr[1])
        dateComponents.day = Int(dateArr[2])
        //trigger 세팅
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
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
    //모든 푸쉬 삭제
    func deleteAllPush() {
        notiCenter.removeAllPendingNotificationRequests()
        print("Delete All Noti")
    }
    //
    func updatePush(_ idList:[String], _ task:EachTask) -> [String] {
        deletePush(idList)
        return addNotification(task)
    }
    //
    func deletePush(_ idList:[String]) {
        notiCenter.removePendingNotificationRequests(withIdentifiers: idList)
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
