//
//  PopCell.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/26.
//

import UIKit

class PopCell: UITableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var categoryLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        initUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //
        labelTitle.textColor = self.isSelected ? .black : .white
    }
    
    private func initUI() {
        // 배경
        self.backgroundColor = .white.withAlphaComponent(0.2)
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        // 선택 시 배경
        let backgroundView = UIView(frame: self.bounds)
        backgroundView.backgroundColor = .white
        self.selectedBackgroundView = backgroundView
        //
        labelTitle.textColor = .white
    }
    
    func inputCell(_ title:String) {
        labelTitle.font = UIFont(name: K_Font_B, size: K_FontSize)
        labelTitle.text = title
        categoryLine.backgroundColor = DataManager.shared.getCategoryColor(title)
    }
}
