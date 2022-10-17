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
        let delete = UIContextualAction(style: .destructive, title: "삭제") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.deleteTask(indexPath)
            success(true)
        }
        delete.backgroundColor = .systemRed
        //index = 0, 왼쪽
        return UISwipeActionsConfiguration(actions:[delete])
    }
    //오른쪽 스와이프
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Done Or Not
        let done = UIContextualAction(style: .normal, title: "Done") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.taskIsDone(true, indexPath)
            success(true)
        }
        done.backgroundColor = .systemIndigo
        
        let notDone = UIContextualAction(style: .normal, title: "Not") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.taskIsDone(false, indexPath)
            success(true)
        }
        notDone.backgroundColor = .systemGray
        //index = 0, 오른쪽
        return UISwipeActionsConfiguration(actions:[notDone, done])
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
            self.deleteTask(indexPath)
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
        let board = UIStoryboard(name: taskInfoBoard, bundle: nil)
        guard let taskInfoVC = board.instantiateViewController(withIdentifier: taskInfoBoard) as? TaskInfoViewController,
              let navigation = self.navigationController as? CustomNavigationController else { return }
        
        taskInfoVC.taskData = taskList[indexPath.row]
        taskInfoVC.modalTransitionStyle = .crossDissolve
        taskInfoVC.modalPresentationStyle = .overCurrentContext
        
        navigation.pushViewController(taskInfoVC)
    }
}

//MARK: - FSCalendar
extension MainViewController : FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    // 특정 날짜 선택 시
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        currntDate = date
        loadTask()
    }
    //Dot 개수
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if haveTaskList.contains(where: { $0 == date }) {
            return 1
        } else {
            return 0
        }
    }
    // 월 넘기기
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        calendar.select(calendar.currentPage)
        currntDate = calendar.currentPage
        loadTask()
    }
    // Dot default 색상 변경
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        if haveTaskList.contains(where: { $0 == date }) {
            return [UIColor.darkGray]
        } else {
            return nil
        }
    }
    // Dot click 색상 변경
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        if haveTaskList.contains(where: { $0 == date }) {
            return [UIColor.red]
        } else {
            return nil
        }
    }
}

