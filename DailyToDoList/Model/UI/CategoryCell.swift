//
//  CategoryCell.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/24.
//

import UIKit

class CategoryCell: UITableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelCounter: UILabel!
    
    
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
        labelTitle.font = UIFont(name: K_Font_B, size: K_FontSize + 2.0)
        labelTitle.tintColor = .label
        labelCounter.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelCounter.tintColor = .label
    }
    
    func inputCell(title:String, counter:Int) {
        labelTitle.text = title
        labelCounter.text = String(counter)
    }
}
