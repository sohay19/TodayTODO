//
//  BackUpCell.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/10.
//

import Foundation
import UIKit

class BackUpCell : UITableViewCell {
    @IBOutlet weak var labelDate: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        //
        initCell()
    }
    
    func initCell() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        //
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //
        labelDate.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelDate.tintColor = .label
    }
}
