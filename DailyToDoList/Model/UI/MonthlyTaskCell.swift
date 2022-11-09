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
        self.selectionStyle = .none
        //
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //
        labelMonthlyTitle.font = UIFont(name: MainFont, size: 24)
        //
        let backgroundView = UIView()
        backgroundView.backgroundColor = .red
        selectedBackgroundView = backgroundView
    }
}
