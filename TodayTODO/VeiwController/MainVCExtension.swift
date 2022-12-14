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
    func numberOfSections(in tableView: UITableView) -> Int {
        switch currentType {
        case .Today:
            return taskList.count
        case .Month:
            guard let taskList = monthlyTaskList[Utils.getDay(monthDate)] else {
                return 0
            }
            return taskList.count
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        var task:EachTask = EachTask()
        switch currentType {
        case .Today:
            taskCell.isToday = true
            task = taskList[indexPath.section]
        case .Month:
            taskCell.isToday = false
            guard let taskList = monthlyTaskList[Utils.getDay(monthDate)] else {
                return UITableViewCell()
            }
            task = taskList[indexPath.section]
        }
        var time = ""
        if !task.taskTime.isEmpty {
            let taskTime = task.taskTime.split(separator: ":")
            time = "\(taskTime[0]):\(taskTime[1])"
        }
        taskCell.inputCell(title: task.title, time: time, color: DataManager.shared.getCategoryColor(task.category))
        taskCell.taskIsDone(task.isDone)
        return taskCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    //MARK: - Swipe
    //왼쪽 스와이프
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var task:EachTask = EachTask()
        switch currentType {
        case .Today:
            task = taskList[indexPath.section]
        case .Month:
            guard let taskList = monthlyTaskList[Utils.getDay(monthDate)] else {
                return nil
            }
            task = taskList[indexPath.section]
        }
        //Done Or Not
        let isDone = task.isDone
        let done = UIContextualAction(style: .normal, title: "") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.taskIsDone(indexPath)
            success(true)
        }
        done.image = UIImage(systemName: isDone ? "xmark" : "highlighter", withConfiguration: mediumConfig)
        done.backgroundColor = isDone ? .lightGray : .systemRed
        //index = 0, 왼쪽
        return UISwipeActionsConfiguration(actions:[done])
    }
    //오른쪽 스와이프
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.deleteTask(indexPath)
            success(true)
        }
        delete.image = UIImage(systemName: "trash.fill", withConfiguration: mediumConfig)
        delete.backgroundColor = .defaultPink!
        //index = 0, 오른쪽
        return UISwipeActionsConfiguration(actions:[delete])
    }
    //MARK: - Event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch currentType {
        case .Today:
            let task = taskList[indexPath.section]
            isTaskOpen = true
            SystemManager.shared.openTaskInfo(.LOOK, date: nil, task: task, load: { [self] in
                loadTask()
                sortTask()
            }, modify: { newTask in
                DataManager.shared.updateTask(newTask)
            })
        case .Month:
            guard let taskList = monthlyTaskList[Utils.getDay(monthDate)] else {
                return
            }
            let task = taskList[indexPath.section]
            isTaskOpen = true
            SystemManager.shared.openTaskInfo(.LOOK, date: nil, task: task, load: { [self] in
                loadTask()
                sortTask()
            }, modify: { newTask in
                DataManager.shared.updateTask(newTask)
            })
        }
    }
}

//MARK: - FSCalendar
extension MainViewController : FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    // 특정 날짜 선택 시
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        monthDate = date
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
        if isMoveToday {
            return
        }
        let curDate = Utils.dateToDateString(calendar.currentPage)
        guard let firstDate = Utils.dateStringToDate(curDate) else {
            return
        }
        monthDate = firstDate
        refresh()
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
