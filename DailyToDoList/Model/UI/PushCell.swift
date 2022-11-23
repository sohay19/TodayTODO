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
    @IBOutlet weak var expandableView: UIView!
    @IBOutlet weak var labelTitle:UILabel!
    @IBOutlet weak var labelAlarmTime:UILabel!
    @IBOutlet weak var labelRepeat:UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var memoView: UITextView!
    @IBOutlet weak var btnArrow: UIImageView!
    
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
        expandableView.backgroundColor = .clear
        memoView.backgroundColor = .clear
        //
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //
        labelTitle.font = UIFont(name: K_Font_B, size: K_FontSize + 2.0)
        labelAlarmTime.font = UIFont(name: E_Font_B, size: E_FontSize)
        labelRepeat.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelTime.font = UIFont(name: E_Font_B, size: E_FontSize)
        memoView.font = UIFont(name: K_Font_B, size: K_FontSize)
        //
        btnArrow.contentMode = .center
        btnArrow.tintColor = .label
        //
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        selectedBackgroundView = backgroundView
    }
    
    func controllMain(_ isOn:Bool) {
        mainView.isHidden = !isOn
        labelTitle.isHidden = !isOn
        labelAlarmTime.isHidden = !isOn
        labelRepeat.isHidden = !isOn
        btnArrow.isHidden = !isOn
        controllExpandable(!isOn)
    }
    
    private func controllExpandable(_ isOn:Bool) {
        expandableView.isHidden = !isOn
        labelTime.isHidden = !isOn
        memoView.isHidden = !isOn
    }
}
