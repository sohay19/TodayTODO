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
}

//cell별 이동 가능 여부
//    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        return false : true
//    }
//    //Row Move
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        let task = taskList[sourceIndexPath.row]
//        taskList.remove(at: sourceIndexPath.row)
//        taskList.insert(task, at: destinationIndexPath.row)
//    }
