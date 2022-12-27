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
        initTabBar()
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView?.delegate = self
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
                selectedImage: UIImage(systemName: icon)?.withConfiguration(boldConfig).withTintColor(.lightGray, renderingMode: .alwaysOriginal)
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
        guard let bannerView = bannerView else { return }
        //
        bannerView.adUnitID = "ca-app-pub-6152243173470406/9345345318"
        bannerView.rootViewController = self
        //
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: view.safeAreaLayoutGuide.bottomAnchor,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    //광고 로드
    func loadAd() {
        guard let bannerView = bannerView else { return }
        bannerView.load(GADRequest())
    }
}

extension CustomTabBarController : GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        // 배너뷰 안보이게
        bannerView.alpha = 0
        // 광고 세팅
        initAdMob()
        UIView.animate(withDuration: 1, animations: {
            // 로드 완료 시 보이도록
            bannerView.alpha = 1
        })
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        // 광고 로드
        loadAd()
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        
    }
}

extension CustomTabBarController : UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // 탭 전환 시
    }
}
