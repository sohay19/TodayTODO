//MonthlyTaskCell
//  PushCell.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/21.
//

import Foundation
import UIKit

class PushCell : UITableViewCell {
    @IBOutlet weak var labelTitle:UILabel!
    @IBOutlet weak var labelAlarmTime:UILabel!
    @IBOutlet weak var labelRepeat:UILabel!
    
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
            labelAlarmTime.textColor = isToday ? .defaultPink : .systemIndigo
            labelRepeat.textColor = isToday ? .defaultPink : .systemIndigo
        } else {
            labelTitle.textColor = .label
            labelAlarmTime.textColor = .label
            labelRepeat.textColor = .label
        }
    }
    
    func initCell() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        //
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //
        labelTitle.font = UIFont(name: MainFont, size: MainFontSize + 3.0)
        labelAlarmTime.font = UIFont(name: NumFont, size: NumFontSize)
        labelRepeat.font = UIFont(name: SubFont, size: SubFontSize)
        //
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        selectedBackgroundView = backgroundView
    }
}
