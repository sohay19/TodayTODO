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
        self.separatorInset.left = 0
        //
        initCell()
    }
    
    func initCell() {
        self.backgroundColor = .clear
        self.selectionStyle = .default
        labelDailyTitle.font = UIFont(name: MainFont, size: 24)
    }
}
