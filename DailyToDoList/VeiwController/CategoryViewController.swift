//
//  CategoryViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit

class CategoryViewController: UIViewController {
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    
    var segmentControl = CustomSegmentControl()
    
    var originList:[String] = []
    var categoryList:[String] = []
    var taskList:[String:[EachTask]] = [:]
    var isRefresh = false
    
    
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
        loadData()
        changeEditMode(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //
        changeEditMode(false)
    }
}

//MARK: - Init
extension CategoryViewController {
    private func initUI() {
        // 배경 설정
        let backgroundView = UIImageView(frame: UIScreen.main.bounds)
        backgroundView.image = UIImage(named: BackgroundImage)
        view.insertSubview(backgroundView, at: 0)
        //
        segmentView.backgroundColor = .clear
        addSegmentcontrol()
        //
        tableView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        tableView.separatorInsetReference = .fromCellEdges
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        tableView.separatorColor = .gray.withAlphaComponent(0.5)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //
        btnSave.titleLabel?.font = UIFont(name: E_Font_B, size: E_FontSize)
        btnSave.tintColor = .label
        btnCancel.titleLabel?.font = UIFont(name: E_Font_B, size: E_FontSize)
        btnCancel.tintColor = .label
        btnEdit.tintColor = .label
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
    
    private func initCell() {
        let nibName = UINib(nibName: "CategoryCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "CategoryCell")
    }
}

//MARK: - Func
extension CategoryViewController {
    private func loadData() {
        originList = UserDefaults.shared.array(forKey: CategoryList) as? [String] ?? [String]()
        categoryList = originList
        for category in categoryList {
            let taskes = DataManager.shared.getTaskCategory(category: category)
            taskList[category] = taskes
        }
        tableView.reloadData()
        if isRefresh {
            endAppearanceTransition()
            isRefresh = false
        }
        SystemManager.shared.closeLoading()
        if isRefresh {
            endAppearanceTransition()
            isRefresh = false
        }
    }
    
    private func changeEditMode(_ isEdit:Bool) {
        tableView.setEditing(isEdit, animated: true)
        btnEdit.setImage(UIImage(systemName: isEdit ? "rectangle.portrait.and.arrow.right" : "scissors")?.withConfiguration(mediumConfig), for: .normal)
        btnSave.isHidden = true
        btnCancel.isHidden = true
    }
    
    func changeMoveMode(_ isMove:Bool) {
        guard let items = self.tabBarController?.tabBar.items else {
            return
        }
        for item in items {
            item.isEnabled = !isMove
        }
        btnEdit.isHidden = isMove
        btnSave.isHidden = !isMove
        btnCancel.isHidden = !isMove
     }
    //
    func deleteCategory(_ cateogry:String) {
        guard let list = taskList[cateogry] else {
            return
        }
        if list.count > 0 {
            
        } else {
            
        }
    }
}


//MARK: - Button Event
extension CategoryViewController {
    @IBAction func clickEdit(_ sender:Any) {
        btnEdit.isSelected = !btnEdit.isSelected
        changeEditMode(btnEdit.isSelected)
    }
    @IBAction func clickSave(_ sender:Any) {
        originList = categoryList
        UserDefaults.shared.set(originList, forKey: CategoryList)
        changeMoveMode(false)
        changeEditMode(false)
    }
    //
    @IBAction func clickCancel(_ sender:Any) {
        categoryList = originList
        changeMoveMode(false)
        changeEditMode(false)
        tableView.reloadData()
    }
}

