//
//  SettingViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit
import MessageUI

class SettingViewController : UIViewController {
    @IBOutlet weak var settingTable:UITableView!
    
    let menuList:[SettingType] = [.Notice, .FAQ, .Backup, .Question, .Reset]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        settingTable.dataSource = self
        settingTable.delegate = self
        //
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        //
        settingTable.isScrollEnabled = false
        //
        SystemManager.shared.closeLoading()
    }
}

//MARK: - init
extension SettingViewController {
    private func initUI() {
        // 배경 설정
        let backgroundView = UIImageView(frame: UIScreen.main.bounds)
        backgroundView.image = UIImage(named: BackgroundImage)
        view.insertSubview(backgroundView, at: 0)
        //
        settingTable.backgroundColor = .clear
        settingTable.separatorColor = .lightGray
        settingTable.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

//MARK: - TableView
extension SettingViewController : UITableViewDelegate, UITableViewDataSource {
    //MARK: - Default
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell") as? SettingCell else {
            return UITableViewCell()
        }
        let title = menuList[indexPath.row].rawValue
        cell.inputCell(title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    //MARK: - Event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch menuList[indexPath.row] {
        case .Notice:
            let board = UIStoryboard(name: noticeBoard, bundle: nil)
            guard let noticeVC = board.instantiateViewController(withIdentifier: noticeBoard) as? NoticeViewController else { return }
            noticeVC.modalTransitionStyle = .crossDissolve
            noticeVC.modalPresentationStyle = .fullScreen
            guard let navigationController = self.navigationController as? CustomNavigationController else { return }
            navigationController.pushViewController(noticeVC)
        case .FAQ:
            let board = UIStoryboard(name: faqBoard, bundle: nil)
            guard let faqVC = board.instantiateViewController(withIdentifier: faqBoard) as? FAQViewController else { return }
            faqVC.modalTransitionStyle = .crossDissolve
            faqVC.modalPresentationStyle = .fullScreen
            guard let navigationController = self.navigationController as? CustomNavigationController else { return }
            navigationController.pushViewController(faqVC)
        case .Backup:
            let board = UIStoryboard(name: backupBoard, bundle: nil)
            guard let backupVC = board.instantiateViewController(withIdentifier: backupBoard) as? BackupViewController else { return }
            backupVC.modalTransitionStyle = .crossDissolve
            backupVC.modalPresentationStyle = .fullScreen
            guard let navigationController = self.navigationController as? CustomNavigationController else { return }
            navigationController.pushViewController(backupVC)
        case .Question:
            //문의 메일 보내기
            SystemManager.shared.openLoading()
            sendEmail()
        case .Reset:
            PopupManager.shared.openYesOrNo(self,
                                            title: "데이터 초기화",
                                            msg: "모든 데이를 삭제하시겠습니까?\n(iCloud 백업 데이터 제외)",
                                            completeYes: { [self] _ in deleteAllFile() })
        }
    }
}

//MARK: - Func
extension SettingViewController {
    private func deleteAllFile() {
        //origin Realm 파일 삭제
        DataManager.shared.deleteRealm()
        //알람 삭제
        DataManager.shared.deleteAllAlarmPush()
        //카테고리 삭제
        DataManager.shared.deleteAllCategory()
    }
}

//MARK: - MessageUI
extension SettingViewController : MFMailComposeViewControllerDelegate {
    private func sendEmail() {
        // 사용자의 메일 계정이 설정되어 있지 않아 메일을 보낼 수 없다는 경고 메시지 추가
        guard MFMailComposeViewController.canSendMail() else { return }
        //메일 내용
        let toRecipents = ["sy40222@gmail.com"]
        let emailTitle = "Daily TOOD 문의/피드백"
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
