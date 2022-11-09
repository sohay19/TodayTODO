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
    
    func initCell() {
        self.backgroundColor = .clear
        self.selectionStyle = .default
        //
        separatorInset.left = 0
        separatorInset.right = 0
        //
        labelDailyTitle.font = UIFont(name: MainFont, size: MainFontSize)
    }
}
