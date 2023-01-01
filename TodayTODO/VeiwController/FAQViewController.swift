//
//  FAQViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/29.
//

import Foundation
import UIKit

class FAQViewController : UIViewController {
    @IBOutlet weak var line:UIView!
    //
    @IBOutlet weak var labelTitle:UILabel!
    @IBOutlet weak var labelNilMsg: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    //
    @IBOutlet weak var faqTable: UITableView!
    
    
    var faqList:[String:[String:String]] = [:]
    var openedIndex:IndexPath?
    //
    let backgroundView = UIImageView(frame: UIScreen.main.bounds)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        faqTable.delegate = self
        faqTable.dataSource = self
        //
        view.insertSubview(backgroundView, at: 0)
        initCell()
        initRefreshController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        //
        initUI()
        loadData()
    }
}

//MARK: - init
extension FAQViewController {
    private func initUI() {
        // 배경 설정
        backgroundView.image = UIImage(named: BackgroundImage)
        line.backgroundColor = .label
        //
        faqTable.backgroundColor = .clear
        faqTable.sectionHeaderTopPadding = 0
        faqTable.sectionFooterHeight = 0
        faqTable.sectionHeaderHeight = 0
        faqTable.separatorInsetReference = .fromCellEdges
        faqTable.separatorColor = .clear
        faqTable.scrollIndicatorInsets = UIEdgeInsets(top: 0, left:0, bottom: 0, right: 0)
        //
        labelTitle.font = UIFont(name: E_Font_B, size: E_FontSize)
        labelNilMsg.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelNilMsg.isHidden = true
        //
        btnBack.setImage(UIImage(systemName: "chevron.backward", withConfiguration: mediumConfig), for: .normal)
        btnBack.tintColor = .label
    }
    //
    func initCell() {
        let nibName = UINib(nibName: "FAQCell", bundle: nil)
        faqTable.register(nibName, forCellReuseIdentifier: "FAQCell")
    }
    //refresh controller 초기세팅
    func initRefreshController() {
        //
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshView), for: .valueChanged)
        //초기화
        refreshControl.endRefreshing()
        faqTable.refreshControl = refreshControl
    }
    @objc func refreshView() {
        faqTable.refreshControl?.endRefreshing()
        faqTable.reloadData()
    }
    //
    private func loadData() {
        FirebaseManager.shared.loadFAQ { [self] isSuccess, data in
            DispatchQueue.main.async { [self] in
                if isSuccess {
                    faqList = data
                    labelNilMsg.isHidden = faqList.count > 0 ? true : false
                } else {
                    print("loadFAQ Error")
                }
                faqTable.reloadData()
                SystemManager.shared.closeLoading()
            }
        }
    }
}

//MARK: - Button Event
extension FAQViewController {
    @IBAction func clickBack(_ sender:Any) {
        guard let navigationController = self.navigationController as? CustomNavigationController else { return }
        navigationController.popViewController()
    }
}

//MARK: - TableView
extension FAQViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //열린 셀 존재
        if let openedIndex = openedIndex {
            if openedIndex.section == section {
                return 2
            }
        }
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return faqList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FAQCell") as? FAQCell else {
            return UITableViewCell()
        }
        let index = String(indexPath.section)
        guard let dic = faqList[index] else {
            return UITableViewCell()
        }
        if let openedIndex = openedIndex {
            if openedIndex.section == indexPath.section {
                // 열린 셀 타이틀
                if indexPath.row == 0 {
                    let title = dic["title"] ?? ""
                    let body = dic["body"] ?? ""
                    cell.controllMain(true)
                    cell.changeArrow(true)
                    cell.inputCell(title, body)
                    return cell
                } else { //열린 셀 내용
                    let title = dic["title"] ?? ""
                    let body = dic["body"] ?? ""
                    cell.controllMain(false)
                    cell.inputCell(title, body)
                    return cell
                }
            }
        }
        let title = dic["title"] ?? ""
        let body = dic["body"] ?? ""
        cell.controllMain(true)
        cell.changeArrow(false)
        cell.inputCell(title, body)
        
        return cell
    }
    //MARK: - Event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = openedIndex {
            openedIndex = nil
        } else {
            openedIndex = indexPath
        }
        faqTable.reloadData()
    }
    //MARK: - Expandable
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 90 : 300
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
}

