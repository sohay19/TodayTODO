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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: UIStackView!
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var premiumView: UIView!
    @IBOutlet weak var btnPremium: UIButton!
    @IBOutlet weak var labelPremium: UILabel!
    @IBOutlet weak var btnAd: UIButton!
    @IBOutlet weak var labelAd: UILabel!
    @IBOutlet weak var line: UIView!
    
    let menuList:[SettingType] = [.Notice, .MyPage, .Custom, .Help, .FAQ, .Question]
    var isRefresh = false
    //
    let backgroundView = UIImageView(frame: UIScreen.main.bounds)
    let constraintId = "bannerHeight"
    var bannerConstraint:NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        tableView.delegate = self
        tableView.dataSource = self
        //
        view.insertSubview(backgroundView, at: 0)
        addNoti()
        //
        bannerConstraint = bannerView.constraints.first(where: { $0.identifier == constraintId })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        tableView.reloadData()
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
        bannerView.layer.borderWidth = 1
        bannerView.layer.borderColor = UIColor.lightGray.cgColor
        bannerView.backgroundColor = .label
        adView.backgroundColor = .clear
        premiumView.backgroundColor = .clear
        line.backgroundColor = .lightGray
        //
        labelInfo.textColor = .gray
        labelInfo.font = UIFont(name: N_Font, size: N_FontSize - 2.0)
        labelPremium.text = "₩3,000"
        labelPremium.textColor = .gray
        labelPremium.font = UIFont(name: N_Font, size: N_FontSize - 2.0)
        labelAd.text = "₩2,200"
        labelAd.textColor = .gray
        labelAd.font = UIFont(name: N_Font, size: N_FontSize - 2.0)
        //
        btnAd.titleLabel?.font = UIFont(name: LogoFont, size: K_FontSize + 6.0)
        btnAd.setTitle("광고제거", for: .normal)
        btnAd.setTitleColor(.systemBackground, for: .normal)
        btnAd.tintColor = .systemIndigo
        btnAd.backgroundColor = .clear
        btnPremium.titleLabel?.font = UIFont(name: LogoFont, size: K_FontSize + 6.0)
        btnPremium.setTitle("테마 + 광고제거", for: .normal)
        btnPremium.setTitleColor(.systemBackground, for: .normal)
        btnPremium.tintColor = .systemIndigo
        btnPremium.backgroundColor = .clear
        //
        let isPurchaseAd = SystemManager.shared.isProductPurchased(IAPAdMob)
        let isPurchaseCustom = SystemManager.shared.isProductPurchased(IAPCustomTab)
        let isPremium = SystemManager.shared.isProductPurchased(IAPPremium)
        if isPremium || isPurchaseCustom && isPurchaseAd {
            bannerView.isHidden = true
            bannerConstraint?.constant = 0
        } else if isPurchaseAd {
            adView.isHidden = true
            line.isHidden = true
        }
    }
    // IAP 노티 구독
    private func addNoti() {
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(handlePurchaseNoti(_:)),
          name: .IAPServicePurchaseNotification,
          object: nil
        )
    }
    @objc private func handlePurchaseNoti(_ notification: Notification) {
        guard let result = notification.object as? (Bool, String) else { return }
        let isSuccess = result.0
        if isSuccess {
            switch result.1 {
            case IAPCustomTab:
                moveCustomUITab()
            case IAPAdMob, IAPPremium:
                PopupManager.shared.openOkAlert(self, title: "알림", msg: "구매가 완료되었습니다\n앱을 종료하고 다시 실행해주세요") { _ in
                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        exit(0)
                    }
                }
            default:
                break
            }
        } else {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "구매 중 오류가 발생하였습니다\n다시 시도해주시기 바랍니다")
        }
    }
    //
    private func loadVersion() {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String,
              let build = dictionary["CFBundleVersion"] as? String
        else { return }
        labelInfo.text = "앱 정보  Ver. \(version) (\(build))"
        //
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
            let board = UIStoryboard(name: NoticeBoard, bundle: nil)
            guard let noticeVC = board.instantiateViewController(withIdentifier: NoticeBoard) as? NoticeViewController else { return }
            noticeVC.modalTransitionStyle = .crossDissolve
            noticeVC.modalPresentationStyle = .fullScreen
            guard let navigationController = self.navigationController as? CustomNavigationController else { return }
            navigationController.pushViewController(noticeVC)
        case .MyPage:
            let board = UIStoryboard(name: MyPageBoard, bundle: nil)
            guard let myPageVC = board.instantiateViewController(withIdentifier: MyPageBoard) as? MyPageViewController else { return }
            myPageVC.modalTransitionStyle = .crossDissolve
            myPageVC.modalPresentationStyle = .fullScreen
            guard let navigationController = self.navigationController as? CustomNavigationController else { return }
            navigationController.pushViewController(myPageVC)
        case .Custom:
            let isPurchase = SystemManager.shared.isProductPurchased(IAPCustomTab)
            if isPurchase {
                self.moveCustomUITab()
            } else {
                PopupManager.shared.openYesOrNo(self, title: "알림",
                                                msg: "구매가 필요한 기능입니다\n(바로 결제되지 않습니다)") { _ in
                    SystemManager.shared.buyProduct(IAPCustomTab)
                }
            }
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
        case .FAQ:
            let board = UIStoryboard(name: FaqBoard, bundle: nil)
            guard let faqVC = board.instantiateViewController(withIdentifier: FaqBoard) as? FAQViewController else { return }
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
    private func moveCustomUITab() {
        let board = UIStoryboard(name: CustomUIBoard, bundle: nil)
        guard let noticeVC = board.instantiateViewController(withIdentifier: CustomUIBoard) as? CustomUIViewController else { return }
        noticeVC.modalTransitionStyle = .crossDissolve
        noticeVC.modalPresentationStyle = .fullScreen
        guard let navigationController = self.navigationController as? CustomNavigationController else { return }
        navigationController.pushViewController(noticeVC)
    }
    @IBAction func clickPremium(_ sender: Any) {
        SystemManager.shared.buyProduct(IAPPremium)
    }
    @IBAction func clickAd(_ sender: Any) {
        SystemManager.shared.buyProduct(IAPAdMob)
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
