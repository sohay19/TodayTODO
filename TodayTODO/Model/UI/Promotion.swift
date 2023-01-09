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
    @IBOutlet weak var ImgView1:UIView!
    @IBOutlet weak var ImgView2:UIView!
    @IBOutlet weak var ImgView3:UIView!
    @IBOutlet weak var textView1:UITextView!
    @IBOutlet weak var textView2:UITextView!
    @IBOutlet weak var textView3:UITextView!
    @IBOutlet weak var btnRepeat:UIButton!
    @IBOutlet weak var btnClose:UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    var controllTabBar:((Bool)->Void)?
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func initUI() {
        // 배경 설정
        let backgroundView = UIImageView(frame: popView.bounds)
        backgroundView.image = UIImage(named: PopBackImage)
        popView.insertSubview(backgroundView, at: 0)
        //그림자
        popView.layer.shadowColor = UIColor.label.withAlphaComponent(0.4).cgColor
        popView.layer.shadowOpacity = 1
        popView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        //
        textView1.isEditable = false
        textView1.isSelectable = false
        textView1.backgroundColor = .clear
        textView2.isEditable = false
        textView2.isSelectable = false
        textView2.backgroundColor = .clear
        textView3.isEditable = false
        textView3.isSelectable = false
        textView3.backgroundColor = .clear
        //
        btnBack.setTitle("", for: .normal)
        btnBack.backgroundColor = .clear
        btnRepeat.setTitleColor(.white, for: .normal)
        btnRepeat.tintColor = .white
        btnClose.tintColor = .white
        btnClose.setImage(UIImage(systemName: "xmark")?.withConfiguration(mediumConfig), for: .normal)
        btnRepeat.titleLabel?.font = UIFont(name: K_Font_B, size: K_FontSize)
        //
        let font = UIFont(name: K_Font_R, size: K_FontSize) ?? UIFont()
        textView1.setLineSpacing("다양한 테마 및 폰트 적용\n=> ₩1,100"
                                 , font: font, color: .white, align: .right)
        textView2.setLineSpacing("하단 광고 제거\n=> ₩2,200"
                                 , font: font, color: .white, align: .right)
        textView3.setLineSpacing("테마 및 폰트 + 광고 제거\n=> ₩3,000"
                                 , font: font, color: .white, align: .right)
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
}
