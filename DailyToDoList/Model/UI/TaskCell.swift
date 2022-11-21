//
//  TaskCell.swift
//  dailytimetable
//
//  Created by 소하 on 2022/10/07.
//

import Foundation
import UIKit

class TaskCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var expandableView: UIView!
    @IBOutlet weak var memoView: UITextView!
    @IBOutlet weak var btnArrow: UIImageView!
    
    var isToday = true
    private var btnArrowSize:CGFloat = 45
    private var btnArrowConstraint:NSLayoutConstraint?
    
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
        } else {
            labelTitle.textColor = .label
        }
    }
    
    func initCell() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        mainView.backgroundColor = .clear
        expandableView.backgroundColor = .clear
        memoView.backgroundColor = .clear
        //
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //
        labelTitle.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelTime.font = UIFont(name: E_N_Font_R, size: E_N_FontSize)
        labelTime.tintColor = .secondaryLabel
        memoView.font = UIFont(name: K_Font_R, size: K_FontSize)
        memoView.isEditable = false
        memoView.isSelectable = false
        memoView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //
        btnArrow.contentMode = .center
        btnArrow.tintColor = .label
        //
        btnArrow.translatesAutoresizingMaskIntoConstraints = false
        btnArrowConstraint = btnArrow.constraints.first { item in
            return item.identifier == "btnArrowWidth"
        }
    }
    
    func controllMain(_ isOn:Bool) {
        mainView.isHidden = !isOn
        labelTitle.isHidden = !isOn
        labelTime.isHidden = !isOn
        btnArrow.isHidden = !isOn
        controllExpandable(!isOn)
        btnArrow.translatesAutoresizingMaskIntoConstraints = false
        btnArrowConstraint?.constant = btnArrowSize
    }
    
    func setMonthCell() {
        controllMain(true)
        btnArrow.isHidden = true
        btnArrow.translatesAutoresizingMaskIntoConstraints = false
        btnArrowConstraint?.constant = 0
    }
    
    private func controllExpandable(_ isOn:Bool) {
        expandableView.isHidden = !isOn
        memoView.isHidden = !isOn
    }
}
