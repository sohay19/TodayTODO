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
        return pushList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let pushCell = tableView.dequeueReusableCell(withIdentifier: "PushCell", for: indexPath) as? PushCell else {
            return UITableViewCell()
        }
        let request = pushList[indexPath.section]
        guard let trigger = request.trigger as? UNCalendarNotificationTrigger else {
            return UITableViewCell()
        }
        guard let taskId = request.content.userInfo[idKey] as? String else {
            return UITableViewCell()
        }
        guard let task = DataManager.shared.getTask(taskId) else {
            return UITableViewCell()
        }
        guard let option = task.optionData else {
            return UITableViewCell()
        }
        guard let date = Calendar.current.date(from: trigger.dateComponents) else {
            return UITableViewCell()
        }
        let repeatDate = Utils.dateToDateString(date)
        pushCell.isToday = segmentControl.selectedSegmentIndex == 0 ? true : false
        pushCell.inputCell(
            title: task.title,
            alarmTime: option.alarmTime,
            repeatDate: repeatDate,
            color: DataManager.shared.getCategoryColor(task.category))
        return pushCell
    }
    //MARK: - Expandable
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
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
        delete.backgroundColor = .defaultPink!
        //index = 0, 오른쪽
        return UISwipeActionsConfiguration(actions:[delete])
    }
    //MARK: - Event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if pushTable.isEditing {
            return
        }
        let request = pushList[indexPath.section]
        guard let taskId = request.content.userInfo[idKey] as? String else {
            return
        }
        guard let task = DataManager.shared.getTask(taskId) else { return }
        isTaskOpen = true
        SystemManager.shared.openTaskInfo(.LOOK, date: nil, task: task, load: loadPushData, modify: { newTask in
            DataManager.shared.updateTask(newTask)
        })
    }
    //MARK: - Edit
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
}
