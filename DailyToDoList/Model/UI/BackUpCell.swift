//
//  BackUpCell.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/10.
//

import Foundation
import UIKit

class BackUpCell : UITableViewCell {
    @IBOutlet weak var labelDate: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        //
        initCell()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        //
        if highlighted {
            labelDate.textColor = .systemPink
        } else {
            labelDate.textColor = .systemBackground
        }
    }
    
    func initCell() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        //
        separatorInset = UIEdgeInsets(top: 0, left: 9, bottom: 0, right: 9)
        //
        labelDate.font = UIFont(name: MenuKORFont, size: MenuKORFontSize)
    }
}
