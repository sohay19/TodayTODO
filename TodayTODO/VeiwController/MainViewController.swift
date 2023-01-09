//
//  MainViewController.swift
//  TodayTODO
//
//  Created by 소하 on 2023/01/09.
//

import UIKit
import GoogleMobileAds

class MainViewController: UIViewController {
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    var bannerView: GADBannerView!
    var tabbarViewController:CustomTabBarController!
    let constraintKey = "adHeight"
    var constraint:NSLayoutConstraint?
    //
    let backgroundView = UIImageView(frame: UIScreen.main.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.alpha = 0
        bannerView?.delegate = self
        //
        view.insertSubview(backgroundView, at: 0)
        //
        constraint = adView.constraints.first(where: { $0.identifier == constraintKey })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 배경 설정
        backgroundView.image = UIImage(named: BackgroundImage)
        // 광고 세팅
        initAdMob()
    }
}

//MARK: - AdMob
extension MainViewController {
    //애드몹 초기화
    func initAdMob() {
        let isPurchase = SystemManager.shared.isProductPurchased(IAPAdMob)
        let isPremium = SystemManager.shared.isProductPurchased(IAPPremium)
        if !(isPurchase || isPremium) {
            guard let bannerView = bannerView else { return }
            bannerView.adUnitID = "ca-app-pub-6152243173470406/9345345318"
            bannerView.rootViewController = self
            //
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            adView.addSubview(bannerView)
            // 배너 사이즈 조정
            bannerView.topAnchor.constraint(equalTo: adView.topAnchor).isActive = true
            bannerView.bottomAnchor.constraint(equalTo: adView.bottomAnchor).isActive = true
            bannerView.leadingAnchor.constraint(equalTo: adView.leadingAnchor).isActive = true
            bannerView.trailingAnchor.constraint(equalTo: adView.trailingAnchor).isActive = true
            // 로드
            loadAd()
        } else {
            guard let constraint = constraint else { return }
            constraint.constant = 0
        }
    }
    //광고 로드
    func loadAd() {
        guard let bannerView = bannerView else { return }
        bannerView.load(GADRequest())
    }
}

extension MainViewController : GADBannerViewDelegate {
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
