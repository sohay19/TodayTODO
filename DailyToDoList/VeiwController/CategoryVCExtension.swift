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
        return categoryList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as? CategoryCell else {
            return UITableViewCell()
        }
        let category = categoryList[indexPath.row]
        guard let list = taskList[category] else {
            return UITableViewCell()
        }
        cell.inputCell(title: category, counter: list.count)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    //MARK: - Edit
    //Row별 EditMode-
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteCategory(categoryList[indexPath.row])
        }
    }

    //MARK: - Move
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let category = categoryList[sourceIndexPath.row]
        categoryList.remove(at: sourceIndexPath.row)
        categoryList.insert(category, at: destinationIndexPath.row)
        //
        changeMoveMode(originList != categoryList ? true : false)
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
