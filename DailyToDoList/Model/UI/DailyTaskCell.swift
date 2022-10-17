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
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
