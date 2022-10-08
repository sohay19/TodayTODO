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

extension PushManager {
    //Noti 생성
    func setNotification(_ data:EachTask) {
        //반복 여부 체크
        switch RepeatType.init(rawValue: data.repeatType) {
        case .EveryDay:
            setRepeatDayNoti(data)
        case .Eachweek:
            for i in 0..<data.weekDayList.count {
                if data.weekDayList[i] {
                    //index + 1
                    setRepeatWeekNoti(data, i+1)
                }
            }
        case .EachMonthOfOnce:
            setRepeatMonthOfOnceNoti(data)
        case .EachMonthOfWeek:
            for i in 0..<data.weekDayList.count {
                if data.weekDayList[i] {
                    //index + 1
                    setRepeatMonthOfWeekNoti(data, i+1)
                }
            }
        case .EachYear:
            setRepeatYearNoti(data)
        default:
            setNotRepeatNoti(data)
        }
    }
    //반복없음
    private func setNotRepeatNoti(_ data:EachTask) {
        //콘텐츠 설정
        let notiContent = setNotiContent(data)
        //push 날짜 설정
        var dateComponents = getDateComponents(data)
        let dateArr = data.taskDate.split(separator: "-")
        dateComponents.year = Int(dateArr[0])
        dateComponents.month = Int(dateArr[1])
        dateComponents.day = Int(dateArr[2])
        //trigger 세팅
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: data.id, content: notiContent, trigger: trigger)
        //
        notiCenter.add(request) { error in
            if let error = error {
                print("Noti Add Error = \(error)")
            }
        }
    }
    //매일 반복
    private func setRepeatDayNoti(_ data:EachTask) {
        //콘텐츠 설정
        let notiContent = setNotiContent(data)
        //push 날짜 설정
        let dateComponents = getDateComponents(data)
        //trigger 세팅
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: data.id, content: notiContent, trigger: trigger)
        //
        notiCenter.add(request) { error in
            if let error = error {
                print("Noti Add Error = \(error)")
            }
        }
    }
    //주 n회 반복
    private func setRepeatWeekNoti(_ data:EachTask, _ weekDay:Int) {
        //콘텐츠 설정
        let notiContent = setNotiContent(data)
        //push 날짜 설정
        var dateComponents = getDateComponents(data)
        dateComponents.weekday = weekDay
        //trigger 세팅
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: data.id, content: notiContent, trigger: trigger)
        //
        notiCenter.add(request) { error in
            if let error = error {
                print("Noti Add Error = \(error)")
            }
        }
    }
    //월 1회 반복
    private func setRepeatMonthOfOnceNoti(_ data:EachTask) {
        //콘텐츠 설정
        let notiContent = setNotiContent(data)
        //push 날짜 설정
        var dateComponents = getDateComponents(data)
        let dateArr = data.taskDate.split(separator: "-")
        dateComponents.day = Int(dateArr[2])
        //trigger 세팅
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: data.id, content: notiContent, trigger: trigger)
        //
        notiCenter.add(request) { error in
            if let error = error {
                print("Noti Add Error = \(error)")
            }
        }
    }
    //월 n회 반복
    private func setRepeatMonthOfWeekNoti(_ data:EachTask, _ weekDay:Int) {
        //콘텐츠 설정
        let notiContent = setNotiContent(data)
        //push 날짜 설정
        var dateComponents = getDateComponents(data)
        dateComponents.weekday = weekDay
        dateComponents.weekdayOrdinal = data.monthOfWeek
        //trigger 세팅
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: data.id, content: notiContent, trigger: trigger)
        //
        notiCenter.add(request) { error in
            if let error = error {
                print("Noti Add Error = \(error)")
            }
        }
    }
    //연 1회 반복
    private func setRepeatYearNoti(_ data:EachTask) {
        //콘텐츠 설정
        let notiContent = setNotiContent(data)
        //push 날짜 설정
        var dateComponents = getDateComponents(data)
        let dateArr = data.taskDate.split(separator: "-")
        dateComponents.month = Int(dateArr[1])
        dateComponents.day = Int(dateArr[2])
        //trigger 세팅
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: data.id, content: notiContent, trigger: trigger)
        //
        notiCenter.add(request) { error in
            if let error = error {
                print("Noti Add Error = \(error)")
            }
        }
    }
    //푸쉬콘텐츠 내용 설정
    private func setNotiContent(_ data:EachTask) -> UNMutableNotificationContent {
        let notiContent = UNMutableNotificationContent()
        //제목내용
        notiContent.title = "\(data.title)"
        notiContent.body = "\(data.memo)"
        //push 메세지에 담긴 데이터
        notiContent.userInfo = ["id":data.id]
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
        //시작 시간 세팅
        var time = data.startTime.split(separator: ":")
        var h = Int(time[0])
        var m = Int(time[1])
        dateComponents.hour = h
        dateComponents.minute = m
        //알람 시간 계산
        let interval = data.alarmTime
        let alarmDate = Calendar.current.date(byAdding: .minute, value: -interval, to: dateComponents.date!)
        guard let alarmDate = alarmDate else {
            return DateComponents()
        }
        //알람 시간 설정
        time = Utils.timeToString(alarmDate).split(separator: ":")
        h = Int(time[0])
        m = Int(time[1])
        dateComponents.hour = h
        dateComponents.minute = m
    
        return dateComponents
    }
}

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
}
