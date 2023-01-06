//
//  MyPageViewController.swift
//  TodayTODO
//
//  Created by 소하 on 2023/01/06.
//

import Foundation
import UIKit

class MyPageViewController : UIViewController {
    @IBOutlet weak var menuTable:UITableView!
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var btnPremium:UIButton!
    @IBOutlet weak var line:UIView!
    @IBOutlet weak var labelTitle:UILabel!
    @IBOutlet weak var labelStore:UILabel!
    @IBOutlet weak var labelTheme:UILabel!
    @IBOutlet weak var labelAd:UILabel!
    @IBOutlet weak var switchTheme:UISwitch!
    @IBOutlet weak var switchAd:UISwitch!
    @IBOutlet weak var labelPremium:UILabel!
    @IBOutlet weak var labelPrice:UILabel!
    
    
    let menuList:[SettingType] = [.Restore, .Backup, .Reset]
    //
    let backgroundView = UIImageView(frame: UIScreen.main.bounds)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        menuTable.delegate = self
        menuTable.dataSource = self
        //
        switchTheme.tag = 0
        switchAd.tag = 1
        view.insertSubview(backgroundView, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        menuTable.reloadData()
        initUI()
    }
}

//MARK: - Func
extension MyPageViewController {
    private func initUI() {
        // 배경 설정
        backgroundView.image = UIImage(named: BackgroundImage)
        line.backgroundColor = .label
        //
        menuTable.backgroundColor = .clear
        menuTable.separatorInsetReference = .fromCellEdges
        menuTable.separatorInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        //폰트 설정
        labelTitle.font = UIFont(name: E_Font_B, size: E_FontSize)
        labelTitle.textColor = .label
        labelStore.font = UIFont(name: K_Font_B, size: K_FontSize)
        labelStore.textColor = .label
        labelTheme.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelTheme.textColor = .label
        labelAd.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelAd.textColor = .label
        labelPremium.font = UIFont(name: LogoFont, size: 21.0)
        labelPremium.textColor = .label
        labelPrice.font = UIFont(name: N_Font, size: N_FontSize)
        labelPrice.textColor = .gray
        //
        let isPurchasePremium = SystemManager.shared.isProductPurchased(IAPPremium)
        let isPurchaseTheme = SystemManager.shared.isProductPurchased(IAPCustomTab)
        let isPurchaseAd = SystemManager.shared.isProductPurchased(IAPAdMob)
        switchTheme.onTintColor = .systemIndigo
        switchAd.onTintColor = .systemIndigo
        switchTheme.isOn = isPurchaseTheme || isPurchasePremium
        switchTheme.isEnabled = !switchTheme.isOn
        switchAd.isOn = isPurchaseAd || isPurchasePremium
        switchAd.isEnabled = !switchAd.isOn
        //
        btnPremium.setTitle("", for: .normal)
        btnPremium.setTitleColor(.label, for: .normal)
        btnPremium.backgroundColor = .lightGray.withAlphaComponent(0.1)
        btnPremium.layer.borderColor = UIColor.gray.cgColor
        btnPremium.layer.borderWidth = 0.3
        btnPremium.layer.cornerRadius = 5
        labelPremium.text = "테마 및 폰트 + 광고제거"
        labelPremium.textAlignment = .center
        labelPrice.text = "₩3,000"
        //
        SystemManager.shared.closeLoading()
    }
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

//MARK: - TableView
extension MyPageViewController : UITableViewDelegate, UITableViewDataSource {
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
        case .Restore:
            PopupManager.shared.openOkAlert(self,
                                            title: "스토어 구매 이력 복원", msg: "구매 이력을 복원합니다") { _ in
                SystemManager.shared.restorePurchases()
            }
        case .Backup:
            let board = UIStoryboard(name:BackupBoard, bundle: nil)
            guard let backupVC = board.instantiateViewController(withIdentifier: BackupBoard) as? BackupViewController else { return }
            backupVC.modalTransitionStyle = .crossDissolve
            backupVC.modalPresentationStyle = .fullScreen
            guard let navigationController = self.navigationController as? CustomNavigationController else { return }
            navigationController.pushViewController(backupVC)
        case .Reset:
            SystemManager.shared.openLoading()
            PopupManager.shared.openYesOrNo(self,
                                            title: "데이터 초기화",
                                            msg: "모든 데이를 삭제하시겠습니까?\n(iCloud 백업 데이터 제외)",
                                            completeYes: { [self] _ in deleteAllFile() },
                                            completeNo: { _ in SystemManager.shared.closeLoading() })
        default:
            break
        }
    }
}

//MARK: - Event
extension MyPageViewController {
    @IBAction func clickSwitch(_ sender:UISwitch) {
        PopupManager.shared.openYesOrNo(self, title: "알림",
                                        msg: "해당 기능을 구매합니다\n(바로 결제되지 않습니다)",
                                        completeYes: { _ in
            SystemManager.shared.openLoading()
            switch sender.tag {
            case 0:
                SystemManager.shared.buyProduct(IAPCustomTab)
            case 1:
                SystemManager.shared.buyProduct(IAPAdMob)
            default:
                break
            }
        }, completeNo: { _ in
            switch sender.tag {
            case 0:
                self.switchTheme.isOn = false
            case 1:
                self.switchAd.isOn = false
            default:
                break
            }
        })
    }
    @IBAction func clickPremium(_ sender:Any) {
        PopupManager.shared.openYesOrNo(self, title: "알림",
                                        msg: "해당 기능을 구매합니다\n(바로 결제되지 않습니다)") { _ in
            SystemManager.shared.openLoading()
            SystemManager.shared.buyProduct(IAPPremium)
        }
    }
    @IBAction func clickBack(_ sender:Any) {
        guard let navigationController = self.navigationController as? CustomNavigationController else { return }
        navigationController.popViewController()
    }
}
