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
        var title = ""
        var font = ""
        switch type {
        case .Barunpen:
            title = "나눔바른펜"
            font = NanumBarunpen_R
        case .SquareNeo:
            title = "나눔스퀘어네오"
            font = NanumSquareNeo_R
        case .SquareRound:
            title = "나눔스퀘어라운드"
            font = NanumSquareRound_R
        }
        labelTitle.text = title
        labelTitle.font = UIFont(name: font, size: K_FontSize)
    }
}
