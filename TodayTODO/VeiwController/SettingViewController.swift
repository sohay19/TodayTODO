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
    @IBOutlet weak var btnView: UIView!
    @IBOutlet weak var backView1: UIView!
    @IBOutlet weak var backView2: UIView!
    @IBOutlet weak var backView3: UIView!
    @IBOutlet weak var backView4: UIView!
    @IBOutlet weak var backView5: UIView!
    @IBOutlet weak var backView6: UIView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var imgView1: UIImageView!
    @IBOutlet weak var imgView2: UIImageView!
    @IBOutlet weak var imgView3: UIImageView!
    @IBOutlet weak var imgView4: UIImageView!
    @IBOutlet weak var imgView5: UIImageView!
    @IBOutlet weak var imgView6: UIImageView!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var btn5: UIButton!
    @IBOutlet weak var btn6: UIButton!
    
    var btnList:[UIButton] = []
    var labelList:[UILabel] = []
    var imgList:[UIImageView] = []
    var viewList:[UIView] = []
    let menuList:[SettingType] = [.Notice, .Backup, .Reset, .Help, .FAQ, .Question]
    var isRefresh = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        //
        SystemManager.shared.openLoading()
        loadVersion()
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
        versionView.backgroundColor = .clear
        btnView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        //
        labelInfo.textColor = .label
        labelInfo.font = UIFont(name: N_Font, size: N_FontSize)
        //
        //
        viewList.append(backView1)
        viewList.append(backView2)
        viewList.append(backView3)
        viewList.append(backView4)
        viewList.append(backView5)
        viewList.append(backView6)
        //
        btnList.append(btn1)
        btnList.append(btn2)
        btnList.append(btn3)
        btnList.append(btn4)
        btnList.append(btn5)
        btnList.append(btn6)
        //
        labelList.append(label1)
        labelList.append(label2)
        labelList.append(label3)
        labelList.append(label4)
        labelList.append(label5)
        labelList.append(label6)
        //
        imgList.append(imgView1)
        imgList.append(imgView2)
        imgList.append(imgView3)
        imgList.append(imgView4)
        imgList.append(imgView5)
        imgList.append(imgView6)
        //
        for i in 0..<menuList.count {
            var title = ""
            var imageName = ""
            if i < menuList.count {
                switch menuList[i] {
                case .Notice:
                    imageName = "list.clipboard"
                case .Backup:
                    imageName = "icloud"
                case .Help:
                    imageName = "questionmark"
                case .Reset:
                    imageName = "trash"
                case .FAQ:
                    imageName = "bubble.left.and.bubble.right"
                case .Question:
                    imageName = "envelope"
                }
                title = menuList[i].rawValue
            }
            //
            labelList[i].text = title
            labelList[i].font = UIFont(name: K_Font_R, size: K_FontSize - 2.0)
            labelList[i].textAlignment = .center
            labelList[i].highlightedTextColor = .systemIndigo
            btnList[i].setTitle(title, for: .normal)
            btnList[i].setTitleColor(.clear, for: .normal)
            //
            let image = UIImage(systemName: imageName, withConfiguration: mediumConfig)
            imgList[i].image = image
            imgList[i].tintColor = .label
            imgList[i].contentMode = .center
            //
            let btnBack = UIImageView(frame: viewList[i].bounds)
            btnBack.image = UIImage(named: BackgroundImage)
            viewList[i].insertSubview(btnBack, at: 0)
            viewList[i].layer.shadowColor = UIColor.gray.cgColor
            viewList[i].layer.shadowOpacity = 0.5
            viewList[i].layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        }
    }
    
    private func loadVersion() {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String,
              let build = dictionary["CFBundleVersion"] as? String
        else { return }
        
        labelInfo.text = "앱 버전  Ver. \(version) (\(build))"
        
        SystemManager.shared.closeLoading()
        if isRefresh {
            endAppearanceTransition()
            isRefresh = false
        }
    }
}

//MARK: - Button Event
extension SettingViewController {
    @IBAction func clickNone(_ sender:UIButton) {
        let type = SettingType(rawValue: sender.title(for: .normal) ?? "")
        // 클릭 효과
        guard let index = menuList.firstIndex(where: {$0 == type}) else {
            return
        }
        imgList[index].tintColor = .systemIndigo
        labelList[index].isHighlighted = true
        UIView.animate(withDuration: 1, delay: 1) { [self] in
            imgList[index].tintColor = .label
            labelList[index].isHighlighted = false
        }
        // 버튼 실행
        switch type {
        case .Notice:
            let board = UIStoryboard(name: noticeBoard, bundle: nil)
            guard let noticeVC = board.instantiateViewController(withIdentifier: noticeBoard) as? NoticeViewController else { return }
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
        default:
            break
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
