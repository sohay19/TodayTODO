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
        let pushData = RealmManager.shared.getTaskData(pushList[indexPath.row].taskId)
        guard let pushData = pushData else {
            return UITableViewCell()
        }
        pushCell.isToday = segmentedController.selectedSegmentIndex == 0 ? true : false
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
                    repeatMsg += Utils.getWeekDayInKOR(weekday)
                }
            }
            repeatMsg.removeLast()
            repeatMsg.removeLast()
            repeatMsg += "요일 반복"
        case .EachOnceOfMonth:
            repeatMsg = "매 월 "
            repeatMsg += String(Utils.getDay(pushData.taskDay))
            repeatMsg += "일 반복"
        case .EachWeekOfMonth:
            repeatMsg = "매 월 "
            repeatMsg += "\(Utils.getWeekOfMonthInKOR(pushData.weekOfMonth))주, "
            var weekDay = pushData.printWeekDay()
            if !weekDay.isEmpty {
                weekDay.removeLast()
            }
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
        //
        let delete = UIContextualAction(style: .normal, title: "삭제") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.deletePush(indexPath)
            success(true)
        }
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = .defaultPink!.withAlphaComponent(0.5)
        //index = 0, 오른쪽
        return UISwipeActionsConfiguration(actions:[delete])
    }
    //MARK: - Event
    //cell 클릭 Event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if pushTable.isEditing {
            return
        }
        let board = UIStoryboard(name: taskInfoBoard, bundle: nil)
        guard let taskInfoVC = board.instantiateViewController(withIdentifier: taskInfoBoard) as? TaskInfoViewController else { return }
        guard let data = RealmManager.shared.getTaskData(pushList[indexPath.row].taskId) else {
            return
        }
        taskInfoVC.taskData = data
        taskInfoVC.modalTransitionStyle = .coverVertical
        taskInfoVC.modalPresentationStyle = .overCurrentContext
        
        present(taskInfoVC, animated: true)
    }
    //MARK: - Edit
    //Row별 EditMode-
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    //EditMode별 Event
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deletePush(indexPath)
        }
    }
    //cell별 이동 가능 여부
//    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        return false : true
//    }
//    //Row Move
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        let task = taskList[sourceIndexPath.row]
//        taskList.remove(at: sourceIndexPath.row)
//        taskList.insert(task, at: destinationIndexPath.row)
//    }
}
