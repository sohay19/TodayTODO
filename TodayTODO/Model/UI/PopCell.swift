//
//  PopCell.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/26.
//

import UIKit

class PopCell: UITableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        initUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func initUI() {
        self.backgroundColor = .clear
        // 배경
        self.contentView.backgroundColor = .systemBackground.withAlphaComponent(0.3)
        self.contentView.layer.cornerRadius = 5
        self.contentView.layer.borderWidth = 0.1
        self.contentView.layer.borderColor = UIColor.systemBackground.cgColor
        self.contentView.clipsToBounds = true
        // 선택 시 배경
        let backgroundView = UIView(frame: self.bounds)
        backgroundView.backgroundColor = .systemIndigo.withAlphaComponent(0.3)
        backgroundView.layer.cornerRadius = 5
        backgroundView.clipsToBounds = true
        self.selectedBackgroundView = backgroundView
        //
        labelTitle.font = UIFont(name: K_Font_B, size: K_FontSize)
    }
    
    func inputCell(_ title:String) {
        labelTitle.text = title
        labelTitle.textColor = DataManager.shared.getCategoryColor(title)
    }
}
