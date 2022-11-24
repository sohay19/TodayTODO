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
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let myLabel = UILabel()
        myLabel.frame = CGRect(x: 0, y: 0, width: 320, height: 30)
        myLabel.font = UIFont(name: K_Font_B, size: K_FontSize + 1.0)
        let category = categoryList[section]
        myLabel.text = category
        myLabel.textColor = DataManager.shared.getCategoryColor(category)

        let headerView = UIView()
        headerView.addSubview(myLabel)

        return headerView
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return categoryList.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categoryList[section]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = categoryList[section]
        guard let taskList = taskList[category] else {
            return 0
        }
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
        var repeatType = ""
        if isNextIndex {
            pushCell.controllMain(false)
        } else {
            pushCell.controllMain(true)
            pushCell.changeArrow(isOpenIndex ? true : false)
            pushCell.isToday = segmentedController.selectedSegmentIndex == 0 ? true : false
            //
            switch RepeatType(rawValue: taskData.repeatType) {
            case .EveryDay:
                repeatType = "매일 반복"
            case .Eachweek:
                repeatType = "매 주 "
                let weekDayList = option.getWeekDayList()
                for weekday in 0..<weekDayList.count {
                    if weekDayList[weekday] {
                        repeatType += Utils.getWeekDayInKOR(weekday)
                    }
                }
                repeatType.removeLast()
                repeatType.removeLast()
                repeatType += "요일 반복"
            case .EachOnceOfMonth:
                repeatType = "매 월 "
                repeatType += String(Utils.getDay(taskData.taskDay))
                repeatType += "일 반복"
            case .EachWeekOfMonth:
                repeatType = "매 월 "
                repeatType += "\(Utils.getWeekOfMonthInKOR(option.weekOfMonth))주, "
                var weekDay = taskData.printWeekDay()
                if !weekDay.isEmpty {
                    weekDay.removeLast()
                }
                repeatType += weekDay
                repeatType += "요일 반복"
            case .EachYear:
                repeatType = "매 년 "
                repeatType += String(Utils.getDay(taskData.taskDay))
                repeatType += "일 반복"
            default:
                //None
                repeatType = "반복 없음"
            }
        }
        pushCell.inputCell(title: taskData.title, memo:taskData.memo ,alarmTime: option.alarmTime, repeatType: repeatType, time: taskData.taskTime)
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
        delete.image = UIImage(systemName: "trash.fill", withConfiguration: mediumConfig)
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
