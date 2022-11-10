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
        return taskList.count
    }
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        taskCell.isToday = segmentedController.selectedSegmentIndex == 0 ? true : false
        taskCell.labelTitle.text = taskList[indexPath.row].title
        
        return taskCell
    }
    //MARK: - Swipe
    //왼쪽 스와이프
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Done Or Not
        let isDone = taskList[indexPath.row].isDone
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
        //
        openTaskInfo(.LOOK, taskList[indexPath.row], nil)
    }
}

//MARK: - FSCalendar
extension MainViewController : FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    // 특정 날짜 선택 시
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        currentDate = date
        changeDay()
    }
    //Dot 개수
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        guard let monthlyTaskList = monthlyTaskList[Utils.getDay(date)] else {
            return 0
        }
        if monthlyTaskList.count > 0 {
            return 1
        } else {
            return 0
        }
    }
    // 월 넘기기
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let curDate = Utils.dateToDateString(calendar.currentPage)
        guard let firstDate = Utils.dateStringToDate(curDate) else {
            return
        }
        currentDate = firstDate
        calendarView.select(currentDate)
        changeDate()
        //
        SystemManager.shared.openLoading()
        loadTask()
    }
    // Dot default 색상 변경
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        guard let monthlyTaskList = monthlyTaskList[Utils.getDay(date)] else {
            return nil
        }
        if monthlyTaskList.count > 0 {
            return [UIColor.secondaryLabel]
        } else {
            return nil
        }
    }
    // Dot click 색상 변경
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        guard let monthlyTaskList = monthlyTaskList[Utils.getDay(date)] else {
            return nil
        }
        if monthlyTaskList.count > 0 {
            return [UIColor.defaultPink!]
        } else {
            return nil
        }
    }
}

