//
//  PopListViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/26.
//

import Foundation
import UIKit


class PopListViewController : UIViewController {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var popView: UITableView!
    @IBOutlet weak var buttonView: UIStackView!
    //
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    
    var categoryList:[String] = []
    var complete:((String)->Void)?
    var cancel:(()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        popView.dataSource = self
        popView.delegate = self
        //
        initUI()
        initCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

//MARK: - init
extension PopListViewController {
    private func initUI() {
        self.view.backgroundColor = .clear
        // 배경 설정
        let backgroundView = UIImageView(frame: backView.bounds)
        backgroundView.image = UIImage(named: BlackBackImage)
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 9
        backView.clipsToBounds = true
        backView.insertSubview(backgroundView, at: 0)
        backView.layer.shadowColor = UIColor.darkGray.cgColor
        backView.layer.shadowOffset = CGSize(width: 0, height: 1)
        backView.layer.shadowOpacity = 0.8
        backView.layer.cornerRadius = 9
        //
        popView.sectionHeaderTopPadding = 0
        popView.sectionFooterHeight = 0
        popView.sectionHeaderHeight = 0
        popView.backgroundColor = .clear
        popView.separatorInsetReference = .fromCellEdges
        popView.separatorColor = .clear
        popView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //
        popView.allowsSelectionDuringEditing = true
        popView.allowsMultipleSelectionDuringEditing = false
        //
        buttonView.backgroundColor = .clear
        buttonView.layer.borderWidth = 0.5
        buttonView.layer.borderColor = UIColor.darkGray.cgColor
        //
        line.backgroundColor = .darkGray
        btnOK.titleLabel?.font = UIFont(name: E_Font_B, size: E_FontSize)
        btnOK.tintColor = .systemBackground
        btnCancel.titleLabel?.font = UIFont(name: E_Font_B, size: E_FontSize)
        btnCancel.tintColor = .systemBackground
    }
    //
    func initCell() {
        let nibName = UINib(nibName: "PopCell", bundle: nil)
        popView.register(nibName, forCellReuseIdentifier: "PopCell")
    }
}

//MARK: - Func
extension PopListViewController {
    
}

//MARK: - Button Event
extension PopListViewController {
    @IBAction func clickOK(_ sender:Any) {
        guard let complete = complete else {
            return
        }
        guard let index = popView.indexPathForSelectedRow else {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "옮겨질 카테고리를 선택하세요")
            return
        }
        complete(categoryList[index.row])
        dismiss(animated: true)
    }
    @IBAction func clickCancel(_ sender:Any) {
        guard let cancel = cancel else {
            return
        }
        cancel()
        dismiss(animated: true)
    }
}

//MARK: - TableView
extension PopListViewController : UITableViewDelegate, UITableViewDataSource {
    //MARK: - Default
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return categoryList.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 3.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PopCell") as? PopCell else {
            return UITableViewCell()
        }
        let currentCategory = categoryList[indexPath.section]
        cell.inputCell(currentCategory)
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    //MARK: - Edit
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
}
