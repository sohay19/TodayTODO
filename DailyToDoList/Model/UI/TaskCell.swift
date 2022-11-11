//
//  TaskCell.swift
//  dailytimetable
//
//  Created by 소하 on 2022/10/07.
//

import Foundation
import UIKit

class TaskCell: UITableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    
    var isToday = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        initCell()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        //
        if highlighted {
            labelTitle.textColor = isToday ? .defaultPink : .systemIndigo
        } else {
            labelTitle.textColor = .label
        }
    }
    
    func initCell() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        //
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //
        labelTitle.font = UIFont(name: K_Font_R, size: K_FontSize)
    }
}
