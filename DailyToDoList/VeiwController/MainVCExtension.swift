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
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch segmentedController.selectedSegmentIndex {
        case 1:
            guard let taskCell = tableView.dequeueReusableCell(withIdentifier: "MonthlyTaskCell", for: indexPath) as? MonthlyTaskCell else {
                return UITableViewCell()
            }
            taskCell.labelMonthlyTitle.text = taskList[indexPath.row].title
            let isDone = taskList[indexPath.row].isDone
            taskCell.accessoryType = isDone ? .checkmark : .none
            
            return taskCell
        default:
            guard let taskCell = tableView.dequeueReusableCell(withIdentifier: "DailyTaskCell", for: indexPath) as? DailyTaskCell else {
                return UITableViewCell()
            }
            taskCell.labelDailyTitle.text = taskList[indexPath.row].title
            let isDone = taskList[indexPath.row].isDone
            taskCell.accessoryType = isDone ? .checkmark : .none
            
            return taskCell
        }
    }
    //왼쪽 스와이프
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Done Or Not
        let done = UIContextualAction(style: .normal, title: "Done") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.taskIsDone(true, indexPath)
            success(true)
        }
        done.backgroundColor = .darkGray
        
        let notDone = UIContextualAction(style: .normal, title: "Not") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.taskIsDone(false, indexPath)
            success(true)
        }
        notDone.backgroundColor = .systemGray
        //index = 0, 왼쪽
        return UISwipeActionsConfiguration(actions:[done, notDone])
    }
    //오른쪽 스와이프
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "삭제") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.deleteTask(indexPath)
            success(true)
        }
        delete.backgroundColor = .systemRed
        
        let modify = UIContextualAction(style: .destructive, title: "수정") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.modifyTask(indexPath)
            success(true)
        }
        modify.backgroundColor = .systemIndigo
        //index = 0, 오른쪽
        return UISwipeActionsConfiguration(actions:[delete, modify])
    }
    //Row별 EditMode-
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if taskList[indexPath.row].isDone {
            dailyTaskTable.cellForRow(at: indexPath)?.editingAccessoryType = .checkmark
        }
        
        return .delete
    }
    //EditMode별 Event
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteTask(indexPath)
        }
    }
    //cell별 이동 가능 여부
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return taskList[indexPath.row].isDone ? false : true
    }
    //Row Move
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let task = taskList[sourceIndexPath.row]
        taskList.remove(at: sourceIndexPath.row)
        taskList.insert(task, at: destinationIndexPath.row)
    }
    //cell 클릭 Event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
        tableView.deselectRow(at: indexPath, animated: false)
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
            return [UIColor.red]
        } else {
            return nil
        }
    }
}

