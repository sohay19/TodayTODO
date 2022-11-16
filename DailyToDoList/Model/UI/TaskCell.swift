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
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var expandableView: UIView!
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
        labelTitle.font = UIFont(name: K_Font_B, size: K_FontSize)
        labelTime.font = UIFont(name: E_N_Font_R, size: E_N_FontSize)
        labelTime.tintColor = .secondaryLabel
        memoView.backgroundColor = .clear
        memoView.font = UIFont(name: K_Font_R, size: K_FontSize)
        memoView.isEditable = false
        memoView.isSelectable = false
        expandableView.backgroundColor = .clear
        //
        btnArrow.image = UIImage(systemName: "chevron.down", withConfiguration: smallConfig)
        btnArrow.contentMode = .center
        btnArrow.tintColor = .label
    }
}
