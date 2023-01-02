//
//  SettingViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit
import MessageUI

class SettingViewController : UIViewController {
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var versionView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    let menuList:[SettingType] = [.Notice, .Custom, .Backup, .Reset, .Help, .FAQ, .Question]
    var isRefresh = false
    //
    let backgroundView = UIImageView(frame: UIScreen.main.bounds)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        tableView.delegate = self
        tableView.dataSource = self
        //
        view.insertSubview(backgroundView, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        tableView.reloadData()
        //
        SystemManager.shared.openLoading()
        //
        initUI()
        loadVersion()
    }
}

//MARK: - init
extension SettingViewController {
    private func initUI() {
        // 배경 설정
        backgroundView.image = UIImage(named: BackgroundImage)
        //
        tableView.separatorInsetReference = .fromCellEdges
        tableView.backgroundColor = .clear
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        versionView.backgroundColor = .clear
        //
        labelInfo.textColor = .gray
        labelInfo.font = UIFont(name: N_Font, size: N_FontSize)
    }
    
    private func loadVersion() {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String,
              let build = dictionary["CFBundleVersion"] as? String
        else { return }
        
        labelInfo.text = "앱 정보  Ver. \(version) (\(build))"
        
        SystemManager.shared.closeLoading()
        if isRefresh {
            endAppearanceTransition()
            isRefresh = false
        }
    }
}

//MARK: - TableView
extension SettingViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as? SettingCell else {
            return UITableViewCell()
        }
        cell.inputCell(menuList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = menuList[indexPath.row]
        // 버튼 실행
        switch type {
        case .Notice:
            let board = UIStoryboard(name: noticeBoard, bundle: nil)
            guard let noticeVC = board.instantiateViewController(withIdentifier: noticeBoard) as? NoticeViewController else { return }
            noticeVC.modalTransitionStyle = .crossDissolve
            noticeVC.modalPresentationStyle = .fullScreen
            guard let navigationController = self.navigationController as? CustomNavigationController else { return }
            navigationController.pushViewController(noticeVC)
        case .Custom:
            let board = UIStoryboard(name: CustomUIBoard, bundle: nil)
            guard let noticeVC = board.instantiateViewController(withIdentifier: CustomUIBoard) as? CustomUIViewController else { return }
            noticeVC.modalTransitionStyle = .crossDissolve
            noticeVC.modalPresentationStyle = .fullScreen
            guard let navigationController = self.navigationController as? CustomNavigationController else { return }
            navigationController.pushViewController(noticeVC)
        case .Backup:
            let board = UIStoryboard(name: backupBoard, bundle: nil)
            guard let backupVC = board.instantiateViewController(withIdentifier: backupBoard) as? BackupViewController else { return }
            backupVC.modalTransitionStyle = .crossDissolve
            backupVC.modalPresentationStyle = .fullScreen
            guard let navigationController = self.navigationController as? CustomNavigationController else { return }
            navigationController.pushViewController(backupVC)
        case .Help:
            var actionList:[(UIAlertAction)->Void] = []
            actionList.append({ _ in
                UserDefaults.shared.set(false, forKey: HelpMainKey)
                UserDefaults.shared.set(false, forKey: HelpCategoryKey)
                UserDefaults.shared.set(false, forKey: HelpPushKey)
            })
            actionList.append({ _ in
                UserDefaults.shared.set(true, forKey: HelpMainKey)
                UserDefaults.shared.set(true, forKey: HelpCategoryKey)
                UserDefaults.shared.set(true, forKey: HelpPushKey)
            })
            actionList.append({ _ in
                ()
            })
            PopupManager.shared.openAlertSheet(self,
                                               title: "도움말 안내",
                                               msg: "원하는 메뉴를 선택하세요",
                                               btnMsg: ["도움말 페이지 보기","도움말 페이지 끄기","취소"],
                                               complete: actionList)
        case .Reset:
            SystemManager.shared.openLoading()
            PopupManager.shared.openYesOrNo(self,
                                            title: "데이터 초기화",
                                            msg: "모든 데이를 삭제하시겠습니까?\n(iCloud 백업 데이터 제외)",
                                            completeYes: { [self] _ in deleteAllFile() },
                                            completeNo: { _ in SystemManager.shared.closeLoading() })
        case .FAQ:
            let board = UIStoryboard(name: faqBoard, bundle: nil)
            guard let faqVC = board.instantiateViewController(withIdentifier: faqBoard) as? FAQViewController else { return }
            faqVC.modalTransitionStyle = .crossDissolve
            faqVC.modalPresentationStyle = .fullScreen
            guard let navigationController = self.navigationController as? CustomNavigationController else { return }
            navigationController.pushViewController(faqVC)
        case .Question:
            SystemManager.shared.openLoading()
            sendEmail()
        }
    }
}

//MARK: - Func
extension SettingViewController {
    private func deleteAllFile() {
        //앱 실행 시 데이터 재전달을 위해
        UserDefaults.shared.set(false, forKey: UpdateAKey)
        //알람 삭제
        DataManager.shared.deleteAllAlarmPush()
        //TODO삭제
        DataManager.shared.deleteAllTask()
        //카테고리 삭제
        DataManager.shared.deleteAllCategory()
        //카테고리 순서
        let orderList = DataManager.shared.getCategoryOrder()
        WatchConnectManager.shared.sendToWatchCategoryOrder(orderList)
        //
        SystemManager.shared.closeLoading()
        if let reloadMainView = WatchConnectManager.shared.reloadMainView {
            reloadMainView()
        }
    }
}

//MARK: - MessageUI
extension SettingViewController : MFMailComposeViewControllerDelegate {
    private func sendEmail() {
        // 사용자의 메일 계정이 설정되어 있지 않아 메일을 보낼 수 없다는 경고 메시지 추가
        guard MFMailComposeViewController.canSendMail() else { return }
        //메일 내용
        let toRecipents = ["sy40222@gmail.com"]
        let emailTitle = "Today TODO 문의/피드백"
        let messageBody = "- OS Version: \(SystemManager.shared.getOsVersion())\n" +
        "- Device: \(SystemManager.shared.getModelName())\n" +
        "- 문의내용: "
        //
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        self.present(mc, animated: true, completion: { SystemManager.shared.closeLoading() })
    }
    //메일 취소시 사라지도록
    @objc(mailComposeController:didFinishWithResult:error:)
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult,error: Error?) {
                controller.dismiss(animated: true)
        }
}
