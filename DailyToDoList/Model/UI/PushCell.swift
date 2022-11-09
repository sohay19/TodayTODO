//
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        initCell()
    }
    
    func initCell() {
        self.backgroundColor = .clear
        self.selectionStyle = .default
        //
        separatorInset.left = 0
        separatorInset.right = 0
        //
        labelTitle.font = UIFont(name: MainFont, size: MainFontSize)
        labelAlarmTime.font = UIFont(name: MenuNUMFont, size: MenuNUMFontSize - 6.0)
        labelRepeat.font = UIFont(name: MainFont, size: MainFontSize - 6.0)
    }
}
