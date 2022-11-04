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
        //
        self.separatorInset.left = 0
        //
        initCell()
    }
    
    func initCell() {
        self.backgroundColor = .clear
        self.selectionStyle = .default
        labelMonthlyTitle.font = UIFont(name: MainFont, size: 24)
    }
}
