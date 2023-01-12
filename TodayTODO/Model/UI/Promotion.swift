//
//  Promotion.swift
//  TodayTODO
//
//  Created by 소하 on 2023/01/09.
//

import Foundation
import UIKit

class Promotion:UIView {
    @IBOutlet weak var popView:UIView!
    @IBOutlet weak var imgView1:UIImageView!
    @IBOutlet weak var imgView2:UIImageView!
    @IBOutlet weak var imgView3:UIImageView!
    @IBOutlet weak var labelText1:UILabel!
    @IBOutlet weak var labelText2:UILabel!
    @IBOutlet weak var labelText3:UILabel!
    @IBOutlet weak var btnBuy1: UIButton!
    @IBOutlet weak var btnBuy2: UIButton!
    @IBOutlet weak var btnBuy3: UIButton!
    @IBOutlet weak var btnRepeat:UIButton!
    @IBOutlet weak var btnClose:UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    var controllTabBar:((Bool)->Void)?
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //
        self.backgroundColor = .clear
        addNoti()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //
        self.backgroundColor = .clear
        addNoti()
    }
    
    func initUI() {
        // 배경 설정
        let backgroundView = UIImageView(frame: popView.bounds)
        backgroundView.image = UIImage(named: PopBackImage)
        popView.insertSubview(backgroundView, at: 0)
        popView.clipsToBounds = true
        //그림자
        popView.layer.shadowColor = UIColor.label.withAlphaComponent(0.4).cgColor
        popView.layer.shadowOpacity = 1
        popView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        //
        btnBack.setTitle("", for: .normal)
        btnBack.backgroundColor = .clear
        btnRepeat.setTitleColor(.white, for: .normal)
        btnRepeat.tintColor = .white
        btnClose.tintColor = .white
        btnClose.setImage(UIImage(systemName: "xmark")?.withConfiguration(mediumConfig), for: .normal)
        btnRepeat.titleLabel?.font = UIFont(name: K_Font_B, size: K_FontSize)
        //
        imgView1.image = UIImage(named: "Promotion1.png")
        imgView1.contentMode = .scaleAspectFill
        imgView1.layer.cornerRadius = 5
        imgView2.image = UIImage(named: "Promotion2.png")
        imgView2.contentMode = .scaleAspectFill
        imgView2.layer.cornerRadius = 5
        imgView3.image = UIImage(named: "Promotion3.png")
        imgView3.contentMode = .scaleAspectFill
        imgView3.layer.cornerRadius = 5
        //
        let font = UIFont(name: K_Font_B, size: K_FontSize) ?? UIFont()
        labelText1.text = "다양한 테마 및 폰트 적용"
        labelText1.textAlignment = .right
        labelText1.textColor = .white
        labelText1.font = font
        labelText2.text = "하단 광고 제거"
        labelText2.textAlignment = .right
        labelText2.textColor = .white
        labelText2.font = font
        labelText3.text = "테마 및 폰트 + 광고 제거"
        labelText3.textAlignment = .right
        labelText3.textColor = .white
        labelText3.font = font
        //
        btnBuy1.setTitle("₩1,100", for: .normal)
        btnBuy1.setTitleColor(.white, for: .normal)
        btnBuy1.titleLabel?.font = UIFont(name: N_Font, size: N_FontSize)
        btnBuy1.backgroundColor = .black
        btnBuy1.layer.cornerRadius = 10
        btnBuy1.tag = 0
        btnBuy2.setTitle("₩2,200", for: .normal)
        btnBuy2.setTitleColor(.white, for: .normal)
        btnBuy2.titleLabel?.font = UIFont(name: N_Font, size: N_FontSize)
        btnBuy2.backgroundColor = .black
        btnBuy2.layer.cornerRadius = 10
        btnBuy2.tag = 1
        btnBuy3.setTitle("₩3,000", for: .normal)
        btnBuy3.setTitleColor(.white, for: .normal)
        btnBuy3.titleLabel?.font = UIFont(name: N_Font, size: N_FontSize)
        btnBuy3.backgroundColor = .black
        btnBuy3.layer.cornerRadius = 10
        btnBuy3.tag = 2
    }
    
    //MARK: - Event
    @IBAction func clickRepeat(_ sender:Any) {
        btnRepeat.isSelected = !btnRepeat.isSelected
        btnRepeat.setImage(UIImage(systemName: btnRepeat.isSelected ? "checkmark.square.fill" : "square.fill"), for: .normal)
        DataManager.shared.setPromotion(btnRepeat.isSelected)
    }
    
    @IBAction func clickClose(_ sender:Any) {
        guard let controllTabBar = controllTabBar else { return }
        self.removeFromSuperview()
        controllTabBar(true)
    }
    
    @IBAction func clickBuy(_ sender:UIButton) {
        var item = ""
        guard let topViewController = SystemManager.shared.topViewController else { return }
        switch sender.tag {
        case 0:
            let isPurchase = UserDefaults.shared.bool(forKey: IAPCustomTab)
            if isPurchase {
                PopupManager.shared.openOkAlert(topViewController,
                                                title: "알림", msg: "이미 구매한 상품입니다")
                break
            }
            item = IAPCustomTab
        case 1:
            let isPurchase = UserDefaults.shared.bool(forKey: IAPAdMob)
            if isPurchase {
                PopupManager.shared.openOkAlert(topViewController,
                                                title: "알림", msg: "이미 구매한 상품입니다")
                break
            }
            item = IAPAdMob
        case 2:
            let isPurchase = UserDefaults.shared.bool(forKey: IAPPremium)
            if isPurchase {
                PopupManager.shared.openOkAlert(topViewController,
                                                title: "알림", msg: "이미 구매한 상품입니다")
                break
            }
            item = IAPPremium
        default:
            break
        }
        SystemManager.shared.buyProduct(item)
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
        guard let topVC = SystemManager.shared.findTopVC() else { return }
        if isSuccess {
            switch result.1 {
            case IAPCustomTab:
                break
            case IAPAdMob, IAPPremium:
                PopupManager.shared.openOkAlert(topVC, title: "알림", msg: "구매가 완료되었습니다\n앱을 종료하고 다시 실행해주세요") { _ in
                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        exit(0)
                    }
                }
            default:
                break
            }
        } else {
            PopupManager.shared.openOkAlert(topVC, title: "알림", msg: "구매 중 오류가 발생하였습니다\n다시 시도해주시기 바랍니다")
        }
    }
}
