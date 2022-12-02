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
    //Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let myLabel = UILabel()
        myLabel.frame = CGRect(x: 6, y: 0, width: 320, height: 30)
        myLabel.font = UIFont(name: K_Font_B, size: K_FontSize + 1.0)
        var list:[String] = []
        switch currentType {
        case .Today:
            list = categoryList
        case .Month:
            list = monthlyTaskList[Utils.getDay(monthDate)]?.categoryList ?? []
        }
        let category = list[section]
        myLabel.text = category
        myLabel.textColor = DataManager.shared.getCategoryColor(category)

        let headerView = UIView()
        let innerView = UIView()
        headerView.addSubview(innerView)
        innerView.translatesAutoresizingMaskIntoConstraints = false
        innerView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        innerView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        innerView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        innerView.heightAnchor.constraint(equalToConstant: 0.3).isActive = true
        innerView.backgroundColor = .gray
        //
        headerView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        headerView.layer.borderWidth = 0.1
        headerView.layer.borderColor = UIColor.gray.cgColor
        headerView.addSubview(myLabel)
        myLabel.translatesAutoresizingMaskIntoConstraints = false
        myLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        myLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 6).isActive = true
        
        return headerView
    }
    //Footer
    func tableView( _ tableView: UITableView, viewForFooterInSection 섹션: Int) -> UIView? {
        let footerView = UIView()
        let innerView = UIView()
        footerView.addSubview(innerView)
        innerView.translatesAutoresizingMaskIntoConstraints = false
        innerView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor).isActive = true
        innerView.trailingAnchor.constraint(equalTo: footerView.trailingAnchor).isActive = true
        innerView.topAnchor.constraint(equalTo: footerView.topAnchor).isActive = true
        innerView.heightAnchor.constraint(equalToConstant: 0.3).isActive = true
        innerView.backgroundColor = .gray
        
        return footerView
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        switch currentType {
        case .Today:
            return categoryList.count
        case .Month:
            guard let list = monthlyTaskList[Utils.getDay(monthDate)]?.categoryList else {
                return 0
            }
            return list.count
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch currentType {
        case .Today:
            return categoryList[section]
        case .Month:
            return monthlyTaskList[Utils.getDay(monthDate)]?.categoryList[section]
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentType {
        case .Today:
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
        case .Month:
            guard let list = monthlyTaskList[Utils.getDay(monthDate)] else {
                return 0
            }
            let category = list.categoryList[section]
            guard let list = list.taskList[category] else {
                return 0
            }
            return list.count
        }
    }
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        var title = ""
        var memo = ""
        var time = ""
        var isDone = false
        switch currentType {
        case .Today:
            var index = indexPath
            var isOpenIndex = false
            var isNextIndex = false
            if let openedTask = openedTask {
                //선택된 다음셀
                let nextIndex = IndexPath(row: openedTask.indexPath.row+1, section: openedTask.indexPath.section)
                if index.section == nextIndex.section && index >= nextIndex {
                    index = IndexPath(row: indexPath.row-1, section: indexPath.section)
                }
                if indexPath == openedTask.indexPath {
                    isOpenIndex = true
                }
                if indexPath == nextIndex {
                    isNextIndex = true
                }
            }
            taskCell.isToday = true
            let category = categoryList[index.section]
            guard let list = resultList[category] else {
                return UITableViewCell()
            }
            let task = list[index.row]
            isDone = task.isDone
            title = task.title
            if isNextIndex {
                //열린 내용셀
                taskCell.controllMain(false)
                memo = task.memo
                if task.taskTime.isEmpty {
                    time = task.taskTime
                } else {
                    let taskTime = task.taskTime.split(separator: ":")
                    time = "\(taskTime[0]):\(taskTime[1])"
                }
                taskCell.taskIsDone(false)
            } else {
                //나머지 셀
                taskCell.controllMain(true)
                taskCell.changeArrow(isOpenIndex ? true : false)
                taskCell.taskIsDone(isDone)
            }
        case .Month:
            taskCell.isToday = false
            guard let list = monthlyTaskList[Utils.getDay(monthDate)] else {
                return UITableViewCell()
            }
            let category = list.categoryList[indexPath.section]
            guard let taskList = list.taskList[category] else {
                return UITableViewCell()
            }
            let task = taskList[indexPath.row]
            isDone = task.isDone
            title = task.title
            taskCell.setMonthCell()
            if task.taskTime.isEmpty {
                time = task.taskTime
            } else {
                let taskTime = task.taskTime.split(separator: ":")
                time = "\(taskTime[0]):\(taskTime[1])"
            }
            taskCell.taskIsDone(isDone)
        }
        taskCell.inputCell(title: title, memo: memo, time: time)
        return taskCell
    }
    //MARK: - Expandable
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch currentType {
        case .Today:
            if let openedTask = openedTask {
                if indexPath == IndexPath(row: openedTask.indexPath.row+1, section: openedTask.indexPath.section) {
                    return 180
                }
                return 45
            }
            return 45
        case .Month:
            return 45
        }
    }
    //MARK: - Swipe
    //왼쪽 스와이프
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var task:EachTask = EachTask()
        switch currentType {
        case .Today:
            let category = categoryList[indexPath.section]
            guard let result = resultList[category]?[indexPath.row] else {
                return nil
            }
            task = result
        case .Month:
            guard let result = monthlyTaskList[Utils.getDay(monthDate)] else {
                return nil
            }
            let category = result.categoryList[indexPath.section]
            guard let taskList = result.taskList[category] else {
                return nil
            }
            task = taskList[indexPath.row]
        }
        //Done Or Not
        let isDone = task.isDone
        let done = UIContextualAction(style: .normal, title: "") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.taskIsDone(!isDone, indexPath)
            success(true)
        }
        done.image = UIImage(systemName: isDone ? "xmark" : "highlighter", withConfiguration: mediumConfig)
        done.backgroundColor = isDone ? UIColor.systemGray.withAlphaComponent(0.5) : UIColor.systemRed.withAlphaComponent(0.5)
        //index = 0, 왼쪽
        return UISwipeActionsConfiguration(actions:[done])
    }
    //오른쪽 스와이프
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let modify = UIContextualAction(style: .normal, title: "") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.modifyTask(indexPath)
            success(true)
        }
        modify.image = UIImage(systemName: "eraser.fill", withConfiguration: mediumConfig)
        modify.backgroundColor = .systemIndigo.withAlphaComponent(0.5)
        
        let delete = UIContextualAction(style: .normal, title: "") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.deleteTask(indexPath)
            success(true)
        }
        delete.image = UIImage(systemName: "trash.fill", withConfiguration: mediumConfig)
        delete.backgroundColor = .defaultPink!.withAlphaComponent(0.5)
        //index = 0, 오른쪽
        return UISwipeActionsConfiguration(actions:[delete, modify])
    }
    //MARK: - Event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = openedTask {
            openedTask = nil
            reloadTable()
        } else {
            switch currentType {
            case .Today:
                let category = categoryList[indexPath.section]
                guard let list = resultList[category] else {
                    return
                }
                let task = list[indexPath.row]
                openedTask = OpenedTask(task.taskId, category, indexPath)
                reloadTable()
            case .Month:
                guard let list = monthlyTaskList[Utils.getDay(monthDate)] else {
                    return
                }
                let category = list.categoryList[indexPath.section]
                guard let taskList = list.taskList[category] else {
                    return
                }
                let task = taskList[indexPath.row]
                isTaskOpen = true
                SystemManager.shared.openTaskInfo(.LOOK, date: nil, task: task, load: loadTask, modify: { newTask in
                    DataManager.shared.updateTask(newTask)
                })
            }
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
