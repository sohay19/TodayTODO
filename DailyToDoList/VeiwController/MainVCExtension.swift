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
    //MARK: - Default
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = categoryList[section]
        switch segmentedController.selectedSegmentIndex {
        case 0:
            guard let list = resultList[category] else {
                return 0
            }
            return list.count
        case 1:
            guard let list = monthlyTaskList[Utils.getDay(currentDate)]?.taskList[category] else {
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
        let category = categoryList[indexPath.section]
        switch segmentedController.selectedSegmentIndex {
        case 0:
            taskCell.isToday = true
            guard let list = resultList[category] else {
                return UITableViewCell()
            }
            taskCell.labelTitle.text = list[indexPath.row].title
        case 1:
            taskCell.isToday = false
            guard let list = monthlyTaskList[Utils.getDay(currentDate)]?.taskList[category] else {
                return UITableViewCell()
            }
            taskCell.labelTitle.text = list[indexPath.row].title
        default:
            return UITableViewCell()
        }
        
        return taskCell
    }
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
        done.image = UIImage(systemName: isDone ? "xmark" : "pencil")
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
        modify.image = UIImage(systemName: "eraser.fill")
        modify.backgroundColor = .systemIndigo.withAlphaComponent(0.5)
        
        let delete = UIContextualAction(style: .destructive, title: "") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.deleteTask(indexPath)
            success(true)
        }
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = .defaultPink!.withAlphaComponent(0.5)
        //index = 0, 오른쪽
        return UISwipeActionsConfiguration(actions:[delete, modify])
    }
    //MARK: - Event
    //cell 클릭 Event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categoryList[indexPath.section]
        switch segmentedController.selectedSegmentIndex {
        case 0:
            guard let list = resultList[category] else {
                return
            }
            openTaskInfo(.LOOK, list[indexPath.row], nil)
        case 1:
            guard let list = monthlyTaskList[Utils.getDay(currentDate)]?.taskList[category] else {
                return
            }
            openTaskInfo(.LOOK, list[indexPath.row], nil)
        default:
            return
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
        guard let list = monthlyTaskList[Utils.getDay(currentDate)] else {
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
        initDate()
        loadTask()
    }
    // Dot default 색상 변경
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        guard let list = monthlyTaskList[Utils.getDay(currentDate)] else {
            return nil
        }
        return list.isEmpty ? nil : [UIColor.secondaryLabel]
    }
    // Dot click 색상 변경
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        guard let list = monthlyTaskList[Utils.getDay(currentDate)] else {
            return nil
        }
        return list.isEmpty ? nil : [UIColor.defaultPink!]
    }
}

