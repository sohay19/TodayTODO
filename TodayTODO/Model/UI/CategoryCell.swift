//
//  CategoryCell.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/24.
//

import UIKit

class CategoryCell: UITableViewCell {
    @IBOutlet weak var categoryLine: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelCounter: UILabel!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var taskList:[EachTask] = []
    var isList = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        initUI()
        registerCell()
    }
    
    private func initUI() {
        self.selectionStyle = .none
        self.shouldIndentWhileEditing = false
        self.backgroundColor = .lightGray.withAlphaComponent(0.1)
        //
        categoryView.backgroundColor = .clear
        listView.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        //
        labelTitle.font = UIFont(name: K_Font_B, size: K_FontSize)
        labelTitle.textColor = .label
        labelCounter.font = UIFont(name: N_Font, size: N_FontSize)
        labelCounter.tintColor = .label
    }
    
    func inputCell(title:String, counter:Int) {
        labelTitle.text = title
        let color = DataManager.shared.getCategoryColor(title)
        categoryLine.backgroundColor = color
        labelCounter.text = String(counter)
    }
    
    func registerCell() {
        collectionView.dataSource = self
        collectionView.delegate = self
        //
        collectionView.register(UINib(nibName: "CategoryTaskCell", bundle: nil), forCellWithReuseIdentifier: "CategoryTaskCell")
    }
    
    func controllMainView(_ isCategory:Bool) {
        controllTableView(!isCategory)
        categoryView.isHidden = !isCategory
        labelTitle.isHidden = !isCategory
        labelCounter.isHidden = !isCategory
    }
    
    private func controllTableView(_ isTable:Bool) {
        listView.isHidden = !isTable
        collectionView.isHidden = !isTable
        //
        collectionView.reloadData()
    }
}

extension CategoryCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return taskList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryTaskCell", for: indexPath) as? CategoryTaskCell else {
            return UICollectionViewCell()
        }
        let task = taskList[indexPath.row]
        cell.initCell(title: task.title, date: task.taskDay)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        SystemManager.shared.openTaskInfo(.LOOK, date: nil, task: task) {
            collectionView.reloadData()
        } modify: { [self] newTask in
            DataManager.shared.updateTask(newTask)
            //카테고리가 바뀌면 삭제
            if newTask.category != task.category {
                taskList.remove(at: indexPath.row)
                return
            }
            //이외엔 업데이트 된 task 저장
            taskList[indexPath.row] = newTask
        }
    }
}

extension CategoryCell: UICollectionViewDelegateFlowLayout {
    // 위 아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    // 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    // cell 사이즈
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: listView.frame.width, height: 45)
        return size
    }
}
