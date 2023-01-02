//
//  FontCell.swift
//  TodayTODO
//
//  Created by 소하 on 2022/12/29.
//

import Foundation
import UIKit

class FontCell: UITableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    
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
    }
    
    func inputCell(_ type:FontType) {
        var font = ""
        var fontSize = 0.0
        switch type {
        case .Barunpen:
            font = NanumBarunpen_R
            fontSize = Barunpen_FontSize
        case .SquareRound:
            font = NanumSquareRound_R
            fontSize = SquareRound_FontSize
        case .GmarketSans:
            font = GmarketSans_R
            fontSize = GmarketSans_FontSize
        case .GangwonEduAll:
            font = GangwonEduAll_R
            fontSize = GangwonEduAll_FontSize
        }
        labelTitle.text = type.rawValue
        labelTitle.font = UIFont(name: font, size: fontSize)
    }
}
