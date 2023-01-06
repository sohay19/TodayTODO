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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        initUI()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        labelTitle.textColor = highlighted ? .systemIndigo : .label
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        // 선택 바로 해제
    }
    
    private func initUI() {
        // 배경
        self.backgroundColor = .clear
        self.selectionStyle = .default
        //
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        selectedBackgroundView = backgroundView
        //
        labelImage.textAlignment = .center
    }
    
    func inputCell(_ type:SettingType) {
        labelTitle.font = UIFont(name: K_Font_B, size: K_FontSize)
        //
        var title = ""
        var imageName = ""
        switch type {
        case .Notice:
            imageName = "list.clipboard"
        case .MyPage:
            imageName = "person"
        case .Restore:
            imageName = "arrow.triangle.2.circlepath"
        case .Custom :
            imageName = "wand.and.stars"
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
