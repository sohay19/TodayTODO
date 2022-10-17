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
        initCell()
    }
    
    func initCell() {
        self.selectionStyle = .default
    }
}
