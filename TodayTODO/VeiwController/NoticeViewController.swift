//
//  NoticeViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/29.
//

import Foundation
import UIKit

class NoticeViewController : UIViewController {
    @IBOutlet weak var line:UIView!
    //
    @IBOutlet weak var labelTitle:UILabel!
    @IBOutlet weak var labelNilMsg: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    //
    @IBOutlet weak var noticeTable: UITableView!
    
    var noticeList:[String:[String:String]] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        noticeTable.delegate = self
        noticeTable.dataSource = self
        //
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

//MARK: - init & func
extension NoticeViewController {
    private func initUI() {
        // 배경 설정
        let backgroundView = UIImageView(frame: UIScreen.main.bounds)
        backgroundView.image = UIImage(named: BackgroundImage)
        view.insertSubview(backgroundView, at: 0)
        line.backgroundColor = .label
        //
        noticeTable.sectionHeaderTopPadding = 0
        noticeTable.backgroundColor = .clear
        noticeTable.separatorInsetReference = .fromCellEdges
        noticeTable.separatorColor = .label
        noticeTable.scrollIndicatorInsets = UIEdgeInsets(top: 0, left:0, bottom: 0, right: 0)
        //
        labelTitle.font = UIFont(name: E_Font_B, size: E_FontSize)
        labelNilMsg.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelNilMsg.isHidden = true
        //
        btnBack.setImage(UIImage(systemName: "chevron.backward", withConfiguration: mediumConfig), for: .normal)
        btnBack.tintColor = .label
    }
    //refresh controller 초기세팅
    func initRefreshController() {
        //
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshView), for: .valueChanged)
        //초기화
        refreshControl.endRefreshing()
        noticeTable.refreshControl = refreshControl
    }
    @objc func refreshView() {
        noticeTable.refreshControl?.endRefreshing()
        noticeTable.reloadData()
    }
    //
    private func loadData() {
        FirebaseManager.shared.loadNotice { [self] isSuccess, data in
            DispatchQueue.main.async { [self] in
                if isSuccess {
                    noticeList = data
                    labelNilMsg.isHidden = noticeList.count > 0 ? true : false
                } else {
                    print("loadNotice Error")
                }
                noticeTable.reloadData()
                SystemManager.shared.closeLoading()
            }
        }
    }
}

//MARK: - Button Event
extension NoticeViewController {
    @IBAction func clickBack(_ sender:Any) {
        guard let navigationController = self.navigationController as? CustomNavigationController else { return }
        navigationController.popViewController()
    }
}

//MARK: - TableView
extension NoticeViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noticeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell") as? NoticeCell else {
            return UITableViewCell()
        }
        let index = String(indexPath.row)
        guard let dic = noticeList[index] else {
            return UITableViewCell()
        }
        let title = dic["title"] ?? ""
        let body = dic["body"] ?? ""
        cell.inputCell(title, body)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 450
    }
}
