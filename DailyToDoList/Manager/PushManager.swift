//
//  PushManager.swift
//  dailytimetable
//
//  Created by 소하 on 2022/09/17.
//

import Foundation
import UserNotifications

class PushManager {
    private let notiCenter = UNUserNotificationCenter.current()
}

//MARK: - Basic
extension PushManager {
    //푸쉬콘텐츠 내용 설정
    private func setNotiContent(_ data:EachTask, _ id:String) -> UNMutableNotificationContent {
        let notiContent = UNMutableNotificationContent()
        //제목내용
        notiContent.title = "\(data.title)"
        notiContent.body = "\(data.memo)"
        //push 메세지에 담긴 데이터
        notiContent.userInfo = ["endDate":data.taskEndDate]
        //알림음 설정
        notiContent.sound = UNNotificationSound.default
        //뱃지 표시
        notiContent.badge = (DataManager.shared.addBadgeCnt()) as NSNumber
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
        print("\(data.alarmTime)")
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
        //반복 여부 체크
        switch RepeatType.init(rawValue: data.repeatType) {
        case .EveryDay:
            idList.append(setRepeatDayNoti(data))
        case .Eachweek:
            //선택 일자 기본 설정
            idList.append(setNotRepeatNoti(data, 0))
            //
            for i in 1..<data.weekDayList.count {
                if data.weekDayList[i] {
                    //index + 1
                    idList.append(setRepeatWeekNoti(data, i+1))
                }
            }
        case .EachMonthOfOnce:
            idList.append(setRepeatMonthOfOnceNoti(data))
        case .EachMonthOfWeek:
            //선택 일자 기본 설정
            idList.append(setNotRepeatNoti(data, 0))
            //
            for i in 0..<data.weekDayList.count {
                if data.weekDayList[i] {
                    //index + 1
                    idList.append(setRepeatMonthOfWeekNoti(data, i+1))
                }
            }
        case .EachYear:
            idList.append(setRepeatYearNoti(data))
        default:
            idList.append(setNotRepeatNoti(data, 0))
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
    private func setRepeatDayNoti(_ data:EachTask) -> String {
        //콘텐츠 설정
        let id = data.id
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
        dateComponents.weekday = weekDay
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
    private func setRepeatMonthOfOnceNoti(_ data:EachTask) -> String {
        //콘텐츠 설정
        let id = data.id
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
    private func setRepeatMonthOfWeekNoti(_ data:EachTask, _ weekDay:Int) -> String {
        //콘텐츠 설정
        let id = "\(data.id)_\(weekDay)"
        let notiContent = setNotiContent(data, id)
        //push 날짜 설정
        var dateComponents = getDateComponents(data)
        dateComponents.weekday = weekDay
        dateComponents.weekdayOrdinal = data.monthOfWeek
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
    private func setRepeatYearNoti(_ data:EachTask) -> String {
        //콘텐츠 설정
        let id = data.id
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
        for id in idList {
            print("삭제된 알람 = \(id)")
        }
    }
}

//MARK: - Etc Event
extension PushManager {
    //권한요청
    func requestPermission() {
        let notiAuthOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
        notiCenter.requestAuthorization(options: notiAuthOptions) { success, error in
            if let error = error {
                print("Noti Permission Error = \(error)")
            } else {
                print("Noti Permission Get!")
            }
        }
    }
    //종료일 체크
    func checkExpiredPush() {
        notiCenter.getPendingNotificationRequests { requestList in
            print("requestCnt = \(requestList.count)")
            for request in requestList {
                let endDate = request.content.userInfo["endDate"] as! String
                let today = Utils.dateToDateString(Date())
                print("종료일 = \(endDate)")
                if endDate == today {
                    let idList = DataManager.shared.findAlarmIdList(request.identifier)
                    self.deletePush(idList)
                }
            }
        }
    }
}
