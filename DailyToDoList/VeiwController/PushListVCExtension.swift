//
//  PushListVCExtension.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/24.
//

import Foundation
import UIKit


extension PushListViewController : UITableViewDelegate, UITableViewDataSource {
    //MARK: - default
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pushList.count
    }
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let pushCell = tableView.dequeueReusableCell(withIdentifier: "PushCell", for: indexPath) as? PushCell else {
            return UITableViewCell()
        }
        guard let pushData = RealmManager.shared.getTaskData(pushList[indexPath.row].taskId) else {
            return UITableViewCell()
        }
        
        pushCell.labelTitle.text = pushData.title
        pushCell.labelAlarmTime.text = pushData.alarmTime
        //
        var repeatMsg = ""
        switch RepeatType(rawValue: pushData.repeatType) {
        case .EveryDay:
            repeatMsg = "매일 반복"
        case .Eachweek:
            repeatMsg = "매 주 "
            let weekDayList = pushData.getWeekDayList()
            for weekday in 0..<weekDayList.count {
                if weekDayList[weekday] {
                    repeatMsg += Utils.getWeekDay(weekday)
                }
            }
            repeatMsg.removeLast()
            repeatMsg.removeLast()
            repeatMsg += "요일 반복"
        case .EachMonthOfOnce:
            repeatMsg = "매 월 "
            repeatMsg += String(Utils.getDay(pushData.taskDay))
            repeatMsg += "일 반복"
        case .EachMonthOfWeek:
            repeatMsg = "매 월 "
            var weekDay = ""
            let weekDayList = pushData.getWeekDayList()
            for weekday in 0..<weekDayList.count {
                if weekDayList[weekday] {
                    repeatMsg += Utils.getWeekDay(weekday)
                }
            }
            if !weekDay.isEmpty {
                weekDay.removeLast()
                weekDay.removeLast()
            }
            repeatMsg += "\(pushData.monthOfWeek)주, "
            repeatMsg += weekDay
            repeatMsg += "요일 반복"
        case .EachYear:
            repeatMsg = "매 년 "
            repeatMsg += String(Utils.getDay(pushData.taskDay))
            repeatMsg += "일 반복"
        default:
            //None
            repeatMsg = "반복 없음"
            
        }
        pushCell.labelRepeat.text = repeatMsg
        
        return pushCell
    }
    
    //MARK: - Swipe
    //오른쪽 스와이프
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Done Or Not
        let modify = UIContextualAction(style: .normal, title: "수정") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            success(true)
        }
        modify.backgroundColor = .systemIndigo
        
        let delete = UIContextualAction(style: .normal, title: "삭제") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            success(true)
        }
        delete.backgroundColor = .systemRed
        //index = 0, 오른쪽
        return UISwipeActionsConfiguration(actions:[delete, modify])
    }
    
    //MARK: - EditMode
    //Row별 EditMode-
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    //EditMode별 Event
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deletePush(indexPath)
        }
    }
    
    //MARK: - Event
    //cell 클릭 Event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let board = UIStoryboard(name: taskInfoBoard, bundle: nil)
        guard let taskInfoVC = board.instantiateViewController(withIdentifier: taskInfoBoard) as? TaskInfoViewController else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        
        taskInfoVC.taskData = RealmManager.shared.getTaskData(pushList[indexPath.row].taskId)
        taskInfoVC.modalTransitionStyle = .crossDissolve
        taskInfoVC.modalPresentationStyle = .overCurrentContext
        
        present(taskInfoVC, animated: true)
    }
}
