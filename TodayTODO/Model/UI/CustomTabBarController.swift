//
//  CustomTabBarController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/18.
//

import Foundation
import UIKit
import GoogleMobileAds

class CustomTabBarController : UITabBarController {
    let iconList:[String] = ["calendar", "list.bullet", "bell", "gearshape"]
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.delegate = self
        self.tabBar.backgroundColor = .clear
        //
        SystemManager.shared.initIAP()
        //
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.alpha = 0
        bannerView?.delegate = self
        // 광고 세팅
        initAdMob()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.setTheme(self)
        initTabBar()
    }
}

extension CustomTabBarController {
    //초기화
    func initTabBar() {
        guard let mainTab = self.storyboard!.instantiateViewController(withIdentifier: mainBoard) as? MainViewController else { return }
        
        let categoryboard = UIStoryboard(name: categoryBoard, bundle: nil)
        guard let categoryTab = categoryboard.instantiateViewController(withIdentifier: categoryBoard) as? CategoryViewController else { return }
        
        let pushboard = UIStoryboard(name: pushBoard, bundle: nil)
        guard let pushTab = pushboard.instantiateViewController(withIdentifier: pushBoard) as? PushListViewController else { return }
        
        let setBoard = UIStoryboard(name: settingBoard, bundle: nil)
        guard let settingTab = setBoard.instantiateViewController(withIdentifier: settingBoard) as? SettingViewController else { return }
        
        self.viewControllers = [mainTab, categoryTab, pushTab, settingTab]
        
        guard let vcList = self.viewControllers else {
            return
        }
        for (i, icon) in iconList.enumerated() {
            let currentTab = vcList[i]
            let tabBarItem = UITabBarItem(
                title: nil,
                image: UIImage(systemName: icon)?.withConfiguration(boldConfig).withTintColor(.label, renderingMode: .alwaysOriginal),
                selectedImage: UIImage(systemName: icon)?.withConfiguration(boldConfig).withTintColor(.systemIndigo, renderingMode: .alwaysOriginal)
            )
            currentTab.tabBarItem = tabBarItem
        }
    }
    // 탭 아이콘 활성화 컨트롤
    func controllTabItem(_ isOn:Bool) {
        guard let list = viewControllers else { return }
        for vc in list {
            vc.tabBarItem.isEnabled = isOn
        }
    }
    //MARK: - AdMob
    //애드몹 초기화
    func initAdMob() {
        let isPurchase = SystemManager.shared.isProductPurchased(IAPAdMob)
        if !isPurchase {
            guard let bannerView = bannerView else { return }
            bannerView.adUnitID = "ca-app-pub-6152243173470406/9345345318"
            bannerView.rootViewController = self
            //
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bannerView)
            // 배너 사이즈 조정
            bannerView.topAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            bannerView.heightAnchor.constraint(equalToConstant: 60).isActive = true
            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            // 전체 뷰 사이즈 조정
            view.translatesAutoresizingMaskIntoConstraints = false
            view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
            view.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height - 60).isActive = true
            // 로드
            loadAd()
        }
    }
    //광고 로드
    func loadAd() {
        guard let bannerView = bannerView else { return }
        bannerView.load(GADRequest())
    }
}

extension CustomTabBarController : GADBannerViewDelegate {
    //로드 완료
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 1
    }
    // 로드 실패
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    // 노출 직전
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        
    }
    // 닫히기 직전
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        
    }
    // 닫힌 순간
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        
    }
    //앱 백그라운드
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        
    }
}

extension CustomTabBarController : UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // 탭 전환 시
        SystemManager.shared.setTheme(viewController)
    }
}
