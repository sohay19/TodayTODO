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
    @IBOutlet weak var btnBack: UIButton!
    
    
    var categoryList:[String] = []
    var complete:((String)->Void)?
    var cancel:(()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        popView.dataSource = self
        popView.delegate = self
        initCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        initUI()
    }
}

//MARK: - init
extension PopListViewController {
    private func initUI() {
        self.view.backgroundColor = .clear
        // 배경 설정
        let backgroundView = UIImageView(frame: backView.bounds)
        backgroundView.image = UIImage(named: WoodBackImage)
        backView.insertSubview(backgroundView, at: 0)
        //그림자
        backView.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        backView.layer.shadowOpacity = 1
        //
        popView.backgroundColor = .clear
        popView.sectionHeaderTopPadding = 0
        popView.sectionFooterHeight = 0
        popView.sectionHeaderHeight = 0
        popView.separatorInsetReference = .fromCellEdges
        popView.separatorColor = .clear
        popView.showsVerticalScrollIndicator = false
        //
        popView.allowsSelectionDuringEditing = true
        popView.allowsMultipleSelectionDuringEditing = false
        //
        buttonView.backgroundColor = .clear
        buttonView.layer.borderWidth = 0.3
        buttonView.layer.borderColor = UIColor.lightGray.cgColor
        //
        line.backgroundColor = .lightGray
        btnOK.tintColor = .black
        btnOK.titleLabel?.font = UIFont(name: K_Font_R, size: K_FontSize)
        btnCancel.tintColor = .black
        btnCancel.titleLabel?.font = UIFont(name: K_Font_R, size: K_FontSize)
        btnBack.tintColor = .clear
        btnBack.backgroundColor = .clear
    }
    //
    func initCell() {
        let nibName = UINib(nibName: "PopCell", bundle: nil)
        popView.register(nibName, forCellReuseIdentifier: "PopCell")
    }
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
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 6
    }
    //MARK: - Edit
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
}
