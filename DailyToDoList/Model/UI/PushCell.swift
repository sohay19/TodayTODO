//MonthlyTaskCell
//  PushCell.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/21.
//

import Foundation
import UIKit

class PushCell : UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var labelTitle:UILabel!
    @IBOutlet weak var labelAlarmTime:UILabel!
    @IBOutlet weak var labelRepeat:UILabel!
    @IBOutlet weak var iconClock: UILabel!
    
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
            labelTitle.textColor = isToday ? .systemIndigo : .defaultPink
            labelAlarmTime.textColor = isToday ? .systemIndigo : .defaultPink
            labelRepeat.textColor = isToday ? .systemIndigo : .defaultPink
        } else {
            labelTitle.textColor = .label
            labelAlarmTime.textColor = .label
            labelRepeat.textColor = .label
        }
    }
    
    func initCell() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        mainView.backgroundColor = .clear
        //
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //
        labelTitle.font = UIFont(name: K_Font_R, size: K_FontSize + 2.0)
        labelAlarmTime.font = UIFont(name: E_Font_B, size: E_FontSize)
        labelRepeat.font = UIFont(name: K_Font_R, size: K_FontSize)
        //
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        selectedBackgroundView = backgroundView
    }
    
    func inputCell(title:String, alarmTime:String, repeatType:String) {
        labelTitle.text = title
        // 알람
        labelAlarmTime.text = alarmTime
        let attributedString = NSMutableAttributedString(string: "")
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "alarm.waves.left.and.right")?.withTintColor(.label).withConfiguration(UIImage.SymbolConfiguration(scale: .medium)).withBaselineOffset(fromBottom: 3)
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        iconClock.attributedText = attributedString
        //
        labelRepeat.text = repeatType
    }
}
