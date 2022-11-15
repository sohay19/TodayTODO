//
//  MainExtension.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/17.
//

import Foundation
import UIKit
import FSCalendar

//MARK: - TableView
extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    //MARK: - Section
    func numberOfSections(in tableView: UITableView) -> Int {
        switch segmentedController.selectedSegmentIndex {
        case 0:
            return categoryList.count
        case 1:
            guard let list = monthlyTaskList[Utils.getDay(currentDate)]?.categoryList else {
                return 0
            }
            return list.count
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch segmentedController.selectedSegmentIndex {
        case 0:
            return categoryList[section]
        case 1:
            return monthlyTaskList[Utils.getDay(currentDate)]?.categoryList[section]
        default:
            return nil
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedController.selectedSegmentIndex {
        case 0:
            let category = categoryList[section]
            guard let list = resultList[category] else {
                return 0
            }
            if let openedTask = openedTask {
                if openedTask.indexPath.section == section {
                    return list.count+1
                } else {
                    return list.count
                }
            } else {
                return list.count
            }
        case 1:
            guard let list = monthlyTaskList[Utils.getDay(currentDate)] else {
                return 0
            }
            let category = list.categoryList[section]
            guard let list = list.taskList[category] else {
                return 0
            }
            return list.count
        default:
            return 0
        }
    }
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        switch segmentedController.selectedSegmentIndex {
        case 0:
            var index = indexPath
            if let openedTask = openedTask {
                let next = IndexPath(row: openedTask.indexPath.row+1, section: openedTask.indexPath.section)
                if index.section == next.section && index > next { //열린 이후의 셀
                    index = IndexPath(row: indexPath.row-1, section: indexPath.section)
                } else if index.section == next.section && index == next { //열린 셀
                    taskCell.labelTitle.text = "열린셀"
                    return taskCell
                }
            }
            taskCell.isToday = true
            let category = categoryList[index.section]
            guard let list = resultList[category] else {
                return UITableViewCell()
            }
            taskCell.labelTitle.text = list[index.row].title
        case 1:
            taskCell.isToday = false
            guard let list = monthlyTaskList[Utils.getDay(currentDate)] else {
                return UITableViewCell()
            }
            let category = list.categoryList[indexPath.section]
            guard let taskList = list.taskList[category] else {
                return UITableViewCell()
            }
            taskCell.labelTitle.text = taskList[indexPath.row].title
        default:
            return UITableViewCell()
        }
        return taskCell
    }
    //MARK: - Expandable
    //
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch segmentedController.selectedSegmentIndex {
        case 0:
            if let openedTask = openedTask {
                if indexPath == IndexPath(row: openedTask.indexPath.row+1, section: openedTask.indexPath.section) {
                    return 180
                }
                return 45
            }
            return 45
        case 1:
            return 45
        default:
            return 0
        }
    }
    //MARK: - Swipe
    //왼쪽 스와이프
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let category = categoryList[indexPath.section]
        var task:EachTask = EachTask()
        switch segmentedController.selectedSegmentIndex {
        case 0:
            guard let result = resultList[category]?[indexPath.row] else {
                return nil
            }
            task = result
        case 1:
            //Month
            guard let result = monthlyTaskList[Utils.getDay(currentDate)]?.taskList[category]?[indexPath.row] else {
                return nil
            }
            task = result
            monthlyTaskTable.reloadRows(at: [indexPath], with: .none)
        default:
            return nil
        }
        //Done Or Not
        let isDone = task.isDone
        let done = UIContextualAction(style: .normal, title: "") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.taskIsDone(!isDone, indexPath)
            success(true)
        }
        done.image = UIImage(systemName: isDone ? "xmark" : "pencil.line", withConfiguration: imageConfig)
        done.backgroundColor = isDone ? UIColor.systemGray.withAlphaComponent(0.5) : UIColor.systemRed.withAlphaComponent(0.5)
        //index = 0, 왼쪽
        return UISwipeActionsConfiguration(actions:[done])
    }
    //오른쪽 스와이프
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let modify = UIContextualAction(style: .destructive, title: "") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.modifyTask(indexPath)
            success(true)
        }
        modify.image = UIImage(systemName: "eraser.fill", withConfiguration: imageConfig)
        modify.backgroundColor = .systemIndigo.withAlphaComponent(0.5)
        
        let delete = UIContextualAction(style: .destructive, title: "") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.deleteTask(indexPath)
            success(true)
        }
        delete.image = UIImage(systemName: "trash.fill", withConfiguration: imageConfig)
        delete.backgroundColor = .defaultPink!.withAlphaComponent(0.5)
        //index = 0, 오른쪽
        return UISwipeActionsConfiguration(actions:[delete, modify])
    }
    //MARK: - Event
    //cell 클릭 Event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = openedTask {
            openedTask = nil
            reloadTable()
        } else {
            switch segmentedController.selectedSegmentIndex {
            case 0:
                let category = categoryList[indexPath.section]
                guard let list = resultList[category] else {
                    return
                }
                let task = list[indexPath.row]
                openedTask = OpenedTask(task.id, category, indexPath)
                reloadTable()
            case 1:
                guard let list = monthlyTaskList[Utils.getDay(currentDate)] else {
                    return
                }
                let category = list.categoryList[indexPath.section]
                guard let taskList = list.taskList[category] else {
                    return
                }
                let task = taskList[indexPath.row]
                openTaskInfo(.LOOK, task, nil)
            default:
                return
            }
        }
    }
}

//MARK: - FSCalendar
extension MainViewController : FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    // 특정 날짜 선택 시
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        currentDate = date
        reloadTable()
    }
    //Dot 개수
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        guard let list = monthlyTaskList[Utils.getDay(date)] else {
            return 0
        }
        return list.isEmpty ? 0 : 1
    }
    // 월 넘기기
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let curDate = Utils.dateToDateString(calendar.currentPage)
        guard let firstDate = Utils.dateStringToDate(curDate) else {
            return
        }
        currentDate = firstDate
        calendarView.select(currentDate)
        //
        SystemManager.shared.openLoading()
        DispatchQueue.main.async { [self] in
            loadTask()
            initDate()
        }
    }
    // Dot default 색상 변경
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        guard let list = monthlyTaskList[Utils.getDay(date)] else {
            return nil
        }
        return list.isEmpty ? nil : [UIColor.secondaryLabel]
    }
    // Dot click 색상 변경
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        guard let list = monthlyTaskList[Utils.getDay(date)] else {
            return nil
        }
        return list.isEmpty ? nil : [UIColor.defaultPink!]
    }
}

