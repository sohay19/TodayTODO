//
//  SettingCell.swift
//  TodayTODO
//
//  Created by 소하 on 2022/12/29.
//

import Foundation
import UIKit

class SettingCell: UITableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelImage: UILabel!
    @IBOutlet weak var labelPurchase: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        initUI()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        labelTitle.textColor = highlighted ? .systemIndigo : .label
    }
    
    private func initUI() {
        // 배경
        self.backgroundColor = .clear
        //
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        selectedBackgroundView = backgroundView
        //
        labelImage.textAlignment = .center
        labelPurchase.textAlignment = .center
        labelPurchase.text = "구매 후 이용이 가능 합니다"
        labelPurchase.textColor = .label
        labelPurchase.font = UIFont(name: K_Font_R, size: K_FontSize - 3.0)
        labelPurchase.backgroundColor = .label.withAlphaComponent(0.05)
        labelPurchase.layer.borderWidth = 0.5
        labelPurchase.layer.borderColor = UIColor.label.cgColor
        labelPurchase.layer.cornerRadius = 5
    }
    
    func inputCell(_ type:SettingType) {
        labelTitle.font = UIFont(name: K_Font_B, size: K_FontSize)
        //
        var title = ""
        var imageName = ""
        switch type {
        case .Notice:
            imageName = "list.clipboard"
            labelPurchase.isHidden = true
        case .Custom :
            imageName = "wand.and.stars"
            //
            let isPurchase = SystemManager.shared.isProductPurchased(IAPCustomTab)
            let isPremium = SystemManager.shared.isProductPurchased(IAPPremium)
            labelPurchase.isHidden = isPurchase || isPremium
        case .Backup:
            imageName = "icloud"
            labelPurchase.isHidden = true
        case .Help:
            imageName = "questionmark"
            labelPurchase.isHidden = true
        case .Reset:
            imageName = "trash"
            labelPurchase.isHidden = true
        case .FAQ:
            imageName = "bubble.left.and.bubble.right"
            labelPurchase.isHidden = true
        case .Question:
            imageName = "envelope"
            labelPurchase.isHidden = true
        }
        title = type.rawValue
        //
        let image = UIImage(systemName: imageName, withConfiguration: mediumConfig)?.withTintColor(.label, renderingMode: .alwaysOriginal)
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        let imageString = NSAttributedString(attachment: imageAttachment)
        let attributedString = NSMutableAttributedString(attributedString: imageString)
        //
        labelTitle.text = title
        labelImage.attributedText = attributedString
    }
}
