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
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //
        labelDate.font = UIFont(name: E_N_Font, size: E_N_FontSize)
    }
}
