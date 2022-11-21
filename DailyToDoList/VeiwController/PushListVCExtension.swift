//
//  PushListVCExtension.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/24.
//

import Foundation
import UIKit


extension PushListViewController : UITableViewDelegate, UITableViewDataSource {
    //MARK: - Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return categoryList.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categoryList[section]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let openedPush = openedPush {
            if openedPush.indexPath.section == section {
                return taskList.count+1
            } else {
                return taskList.count
            }
        }
        return taskList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let pushCell = tableView.dequeueReusableCell(withIdentifier: "PushCell", for: indexPath) as? PushCell else {
            return UITableViewCell()
        }
        var index = indexPath
        var isOpenIndex = false
        var isNextIndex = false
        if let openedPush = openedPush {
            //선택된 다음셀
            let nextIndex = IndexPath(row: openedPush.indexPath.row+1, section: openedPush.indexPath.section)
            if index.section == nextIndex.section && index >= nextIndex {
                index = IndexPath(row: indexPath.row-1, section: indexPath.section)
            }
            if indexPath == openedPush.indexPath {
                isOpenIndex = true
            }
            if indexPath == nextIndex {
                isNextIndex = true
            }
        }
        let category = categoryList[index.section]
        guard let taskData = taskList[category]?[index.row] else {
            return UITableViewCell()
        }
        let option = taskData.optionData ?? OptionData()
        //
        if isNextIndex {
            pushCell.controllMain(false)
            pushCell.labelTime.text = taskData.taskTime
            pushCell.memoView.text = taskData.memo
        } else {
            pushCell.controllMain(true)
            pushCell.btnArrow.image = UIImage(systemName: isOpenIndex ? "chevron.up" : "chevron.down", withConfiguration: thinConfig)
            pushCell.isToday = segmentedController.selectedSegmentIndex == 0 ? true : false
            pushCell.labelTitle.text = taskData.title
            pushCell.labelAlarmTime.text = option.alarmTime
            //
            var repeatMsg = ""
            switch RepeatType(rawValue: taskData.repeatType) {
            case .EveryDay:
                repeatMsg = "매일 반복"
            case .Eachweek:
                repeatMsg = "매 주 "
                let weekDayList = option.getWeekDayList()
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
                repeatMsg += String(Utils.getDay(taskData.taskDay))
                repeatMsg += "일 반복"
            case .EachWeekOfMonth:
                repeatMsg = "매 월 "
                repeatMsg += "\(Utils.getWeekOfMonthInKOR(option.weekOfMonth))주, "
                var weekDay = taskData.printWeekDay()
                if !weekDay.isEmpty {
                    weekDay.removeLast()
                }
                repeatMsg += weekDay
                repeatMsg += "요일 반복"
            case .EachYear:
                repeatMsg = "매 년 "
                repeatMsg += String(Utils.getDay(taskData.taskDay))
                repeatMsg += "일 반복"
            default:
                //None
                repeatMsg = "반복 없음"
            }
            pushCell.labelRepeat.text = repeatMsg
        }
        return pushCell
    }
    //MARK: - Expandable
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let openedPush = openedPush {
            if indexPath == IndexPath(row: openedPush.indexPath.row+1, section: openedPush.indexPath.section) {
                return 180
            }
            return 112
        }
        return 112
    }
    //MARK: - Swipe
    //오른쪽 스와이프
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //
        let delete = UIContextualAction(style: .normal, title: "") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.deletePush(indexPath)
            success(true)
        }
        delete.image = UIImage(systemName: "trash.fill", withConfiguration: regularConfig)
        delete.backgroundColor = .defaultPink!.withAlphaComponent(0.5)
        //index = 0, 오른쪽
        return UISwipeActionsConfiguration(actions:[delete])
    }
    //MARK: - Event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if pushTable.isEditing {
            return
        }
        if let _ = openedPush {
            openedPush = nil
            pushTable.reloadData()
        } else {
            let category = categoryList[indexPath.section]
            guard let task = taskList[category]?[indexPath.row] else {
                return
            }
            openedPush = OpenedTask(task.taskId, categoryList[indexPath.section], indexPath)
            pushTable.reloadData()
        }
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
