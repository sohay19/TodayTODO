//
//  CategoryVCExtension.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/24.
//

import Foundation
import UIKit


//MARK: - tableView
extension CategoryViewController : UITableViewDelegate, UITableViewDataSource {
    //MARK: - Default
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let openIndex = openIndex {
            return openIndex.section == section ? 2 : 1
        }
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return categoryList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as? CategoryCell else {
            return UITableViewCell()
        }
        let category = categoryList[indexPath.section]
        guard let list = taskList[category] else {
            return UITableViewCell()
        }
        if let openIndex = openIndex {
            if openIndex.section == indexPath.section && indexPath.row == 1 {
                cell.taskList = list
                cell.isList = true
                cell.controllMainView(false)
                return cell
            }
        }
        cell.inputCell(title: category, counter: list.count)
        cell.isList = false
        cell.controllMainView(true)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let openIndex = openIndex {
            if openIndex.section == indexPath.section {
                return indexPath.row == 0 ? 45 : 240
            }
        }
        return 45
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 6
    }
    //MARK: - Edit
    //Row별 EditMode-
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    //MARK: - Swipe
    //오른쪽 스와이프
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let modify = UIContextualAction(style: .normal, title: "") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.modifyCategory(indexPath)
            success(true)
        }
        modify.image = UIImage(systemName: "eraser.fill", withConfiguration: mediumConfig)
        modify.backgroundColor = .systemIndigo
        //
        let delete = UIContextualAction(style: .normal, title: "") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.deleteCategory(indexPath)
            success(true)
        }
        delete.image = UIImage(systemName: "trash.fill", withConfiguration: mediumConfig)
        delete.backgroundColor = .defaultPink!
        //index = 0, 오른쪽
        if categoryList[indexPath.section] == "TODO" {
            return nil
        } else if openIndex?.section == indexPath.section && indexPath.row == 1 {
            return nil
        } else {
            return UISwipeActionsConfiguration(actions:[delete, modify])
        }
    }
    //MARK: - Event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = openIndex {
            openIndex = nil
        } else {
            openIndex = indexPath
        }
        tableView.reloadData()
    }
    //MARK: - Move
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let category = categoryList[sourceIndexPath.section]
        categoryList.remove(at: sourceIndexPath.section)
        categoryList.insert(category, at: destinationIndexPath.section)
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    //MARK: - ETC
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
