//
//  CategoryViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit

class CategoryViewController: UIViewController {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnEdit: UIButton!
    
    
    var segmentControl = CustomSegmentControl()
    
    var originList:[String] = []
    var categoryList:[String] = []
    var taskList:[String:[EachTask]] = [:]
    var isRefresh = false
    var isEdit = false
    var openIndex:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        tableView.dataSource = self
        tableView.delegate = self
        //
        initUI()
        initCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        SystemManager.shared.openHelp(self, categoryBoard)
        loadData()
        changeEditMode(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //
        changeEditMode(false)
        openIndex = nil
    }
}

//MARK: - Init
extension CategoryViewController {
    private func initUI() {
        // 배경 설정
        let backgroundView = UIImageView(frame: UIScreen.main.bounds)
        backgroundView.image = UIImage(named: BackgroundImage)
        view.insertSubview(backgroundView, at: 0)
        // 상단 segment
        segmentView.backgroundColor = .clear
        addSegmentcontrol()
        // 배경 및 테두리
        backView.backgroundColor = .clear
        backView.layer.cornerRadius = 5
        backView.layer.borderColor = UIColor.gray.cgColor
        backView.layer.borderWidth = 0.2
        //
        tableView.backgroundColor = .clear
        tableView.sectionFooterHeight = 0
        tableView.sectionHeaderHeight = 0
        tableView.separatorInsetReference = .fromCellEdges
        tableView.separatorColor = .clear
        tableView.showsVerticalScrollIndicator = false
        //
        btnEdit.tintColor = .label
        btnEdit.contentMode = .center
    }
    //
    private func addSegmentcontrol() {
        let segment = CustomSegmentControl(items: ["Category"])
        segment.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: segmentView.frame.size)
        segment.addTarget(self, action: #selector(changeSegment(_:)), for: .valueChanged)
        segment.selectedSegmentIndex = 0
        segmentControl = segment
        segmentView.addSubview(segment)
    }
    @objc private func changeSegment(_ sender:Any) {
        refresh()
    }
    private func refresh() {
        isRefresh = true
        beginAppearanceTransition(true, animated: true)
    }
    //
    private func initCell() {
        let nibName = UINib(nibName: "CategoryCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "CategoryCell")
    }
}

//MARK: - Func
extension CategoryViewController {
    private func loadData() {
        originList = DataManager.shared.getCategoryOrder()
        categoryList = originList
        //
        for category in categoryList {
            var taskes = DataManager.shared.getTaskCategory(category: category)
            taskes.sort(by: { $0.taskDay > $1.taskDay })
            taskList[category] = taskes
        }
        tableView.reloadData()
        SystemManager.shared.closeLoading()
        if isRefresh {
            endAppearanceTransition()
            isRefresh = false
        }
    }
    //
    private func changeEditMode(_ isEdit:Bool) {
        self.isEdit = isEdit
        if isEdit {
            openIndex = nil
            tableView.reloadData()
        }
        tableView.setEditing(isEdit, animated: true)
        btnEdit.setImage(UIImage(systemName: isEdit ? "rectangle.portrait.and.arrow.right" : "scissors")?.withConfiguration(mediumConfig), for: .normal)
    }
    //
    func deleteCategory(_ indexPath:IndexPath) {
        let category = categoryList[indexPath.section]
        PopupManager.shared.openYesOrNo(self, title: "카테고리 삭제", msg: "카테고리를 삭제하시겠습니까?") { [self] _ in
            guard let list = taskList[category] else {
                return
            }
            if list.count > 0 {
                var actionList:[(UIAlertAction)->Void] = []
                guard let list = taskList[category] else {
                    return
                }
                //모두 삭제
                actionList.append { [self] _ in
                    for task in list {
                        DataManager.shared.deleteTask(task)
                    }
                    DataManager.shared.deleteCategory(category)
                    refresh()
                }
                //옮기기
                actionList.append { [self] _ in
                    let board = UIStoryboard(name: PopListBoard, bundle: nil)
                    guard let poplistVC = board.instantiateViewController(withIdentifier: PopListBoard) as? PopListViewController else { return }
                    // 팝업을 위한 세팅
                    poplistVC.modalTransitionStyle = .coverVertical
                    poplistVC.modalPresentationStyle = .overCurrentContext
                    var newList = categoryList
                    guard let index = newList.firstIndex(of: category) else { return }
                    newList.remove(at: index)
                    poplistVC.categoryList = newList
                    // 옮겨질 카테고리 선택
                    poplistVC.complete = { [self] selectedCategory in
                        for task in list {
                            let newTask = task.clone()
                            newTask.setCategory(selectedCategory)
                            DataManager.shared.updateTask(newTask)
                        }
                        DataManager.shared.deleteCategory(category)
                        refresh()
                    }
                    // 취소
                    poplistVC.cancel = { [self] in
                        changeEditMode(false)
                    }
                    // 팝업 띄우기
                    guard let navigationController = self.navigationController as? CustomNavigationController else { return }
                    navigationController.present(poplistVC, animated: true)
                }
                //취소
                actionList.append { [self] _ in
                    changeEditMode(false)
                }
                PopupManager.shared.openAlertSheet(
                    self, title: "카테고리 삭제",
                    msg: "카테고리에 TODO가 존재합니다.\n정말 삭제하시겠습니까?",
                    btnMsg: ["포함된 TODO 모두 삭제", "다른 카테고리로 TODO 옮기기", "취소"],
                    complete: actionList
                    )
            } else {
                DataManager.shared.deleteCategory(category)
                refresh()
            }
        }
    }
    //
    func modifyCategory(_ indexPath:IndexPath) {
        let category = categoryList[indexPath.section]
        //
        let board = UIStoryboard(name: addCategoryBoard, bundle: nil)
        guard let addCategoryVC = board.instantiateViewController(withIdentifier: addCategoryBoard) as? AddCategoryViewController else { return }
        addCategoryVC.categoryInfo = category
        addCategoryVC.reloadCategory = refresh
        addCategoryVC.modalTransitionStyle = .coverVertical
        addCategoryVC.modalPresentationStyle = .overFullScreen
        guard let navigation = self.navigationController as? CustomNavigationController else {
            return
        }
        navigation.present(addCategoryVC, animated: true)
    }
}


//MARK: - Button Event
extension CategoryViewController {
    @IBAction func clickEdit(_ sender:Any) {
        if tableView.isEditing {
            if originList != categoryList {
                PopupManager.shared.openYesOrNo(
                    self,
                    title: "카테고리 순서 변경", msg: "현재 상태를 저장하시곘습니까?") { [self] _ in
                        originList = categoryList
                        DataManager.shared.setCategoryOrder(originList)
                        changeEditMode(false)
                    } completeNo: { [self] _ in
                        categoryList = originList
                        changeEditMode(false)
                        tableView.reloadData()
                    }
            } else {
                changeEditMode(false)
            }
        } else {
            changeEditMode(true)
        }
    }
}

