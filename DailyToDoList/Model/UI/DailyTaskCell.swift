//
//  TaskCell.swift
//  dailytimetable
//
//  Created by 소하 on 2022/10/07.
//

import Foundation
import UIKit

class DailyTaskCell: UITableViewCell {
    @IBOutlet weak var labelDailyTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        initCell()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //
        if selected {
            setSelected(false, animated: false)
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        //
        if highlighted {
            labelDailyTitle.textColor = .systemIndigo
        } else {
            labelDailyTitle.textColor = .label
        }
    }
    func initCell() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        //
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //
        labelDailyTitle.font = UIFont(name: MainFont, size: MainFontSize)
        //
        let backgroundView = UIView()
        backgroundView.backgroundColor = .red
        selectedBackgroundView = backgroundView
    }
}
