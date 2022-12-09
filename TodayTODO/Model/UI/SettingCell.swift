//
//  SettingCell.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/29.
//

import Foundation
import UIKit

class SettingCell: UITableViewCell {
    @IBOutlet weak var labelTitle:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        initUI()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        //
        labelTitle.textColor = highlighted ? .systemIndigo : .label
    }
    
    private func initUI() {
        // 배경
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.separatorInset = UIEdgeInsets(top: 0, left: 9, bottom: 0, right: 9)
        //
        labelTitle.font = UIFont(name: K_Font_B, size: K_FontSize)
    }
    
    func inputCell(_ title:String) {
        labelTitle.text = title
    }
}
