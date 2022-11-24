//
//  CategoryViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit

class CategoryViewController: UIViewController {
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    
    var categoryList:[String] = []
    var taskList:[String:[EachTask]] = [:]
    
    
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
}

//MARK: - Init
extension CategoryViewController {
    private func initUI() {
        // 배경 설정
        let backgroundView = UIImageView(frame: UIScreen.main.bounds)
        backgroundView.image = UIImage(named: BackgroundImage)
        view.insertSubview(backgroundView, at: 0)
        //
        line.backgroundColor = .systemBackground.withAlphaComponent(0.2)
        //
        labelTitle.font = UIFont(name: E_Font_E, size: MenuFontSize)
        labelTitle.textColor = .label
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
    
    private func initCell() {
        let nibName = UINib(nibName: "CategoryCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "CategoryCell")
    }
}

//MARK: - Func
extension CategoryViewController {
    private func loadData() {
        let list = DataManager.shared.loadCategory()
        for category in list {
            let categoryName = category.title
            categoryList.append(categoryName)
            let taskes = DataManager.shared.getTaskCategory(category: categoryName)
            taskList[categoryName] = taskes
        }
        SystemManager.shared.closeLoading()
    }
    
    private func changeEditMode(_ isEdit:Bool) {
        btnEdit.setImage(UIImage(systemName: isEdit ? "rectangle.portrait.and.arrow.right" : "scissors")?.withConfiguration(mediumConfig), for: .normal)
        btnSave.isHidden = true
        btnCancel.isHidden = true
    }
    
    private func changeMoveMode(_ isMove:Bool) {
        btnEdit.isHidden = isMove
        btnSave.isHidden = !isMove
        btnCancel.isHidden = !isMove
    }
}


//MARK: - Button Event
extension CategoryViewController {
    @IBAction func clickSave(_ sender:Any) {
        
    }
    //
    @IBAction func clickCancel(_ sender:Any) {
        
    }
}

