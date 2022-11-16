//
//  ExpandableCell.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/16.
//

import UIKit

class ExpandableCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension ExpandableCell {
    func initUI() {
        
    }
}
