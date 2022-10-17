//
//  MonthlyTaskCell.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/17.
//


import Foundation
import UIKit

class MonthlyTaskCell: UITableViewCell {
    @IBOutlet weak var labelMonthlyTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initCell()
    }
    
    func initCell() {
        self.selectionStyle = .default
    }
}
