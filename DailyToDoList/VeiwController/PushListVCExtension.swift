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
        guard let list = pushList[category] else {
            return 0
        }
        return list.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let pushCell = tableView.dequeueReusableCell(withIdentifier: "PushCell", for: indexPath) as? PushCell else {
            return UITableViewCell()
        }
        let category = categoryList[indexPath.section]
        guard let request = pushList[category]?[indexPath.row] else {
            return UITableViewCell()
        }
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
        pushCell.inputCell(title: task.title, alarmTime: option.alarmTime, repeatDate: repeatDate)
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
        delete.backgroundColor = .defaultPink!.withAlphaComponent(0.5)
        //index = 0, 오른쪽
        return UISwipeActionsConfiguration(actions:[delete])
    }
    //MARK: - Event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if pushTable.isEditing {
            return
        }
        let category = categoryList[indexPath.section]
        guard let request = pushList[category]?[indexPath.row] else {
            return
        }
        guard let taskId = request.content.userInfo[idKey] as? String else {
            return
        }
        guard let task = DataManager.shared.getTask(taskId) else { return }
        isTaskOpen = true
        SystemManager.shared.openTaskInfo(.LOOK, date: nil, task: task, load: nil, modify: nil)
    }
    //MARK: - Edit
    //Row별 EditMode-
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
}
