//
//  CategoryTaskCell.swift
//  TodayTODO
//
//  Created by 소하 on 2022/12/12.
//

import UIKit

class CategoryTaskCell: UICollectionViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var categoryLine: UIView!
    @IBOutlet weak var underline: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        initUI()
    }
    
    private func initUI() {
        self.backgroundColor = .clear
    }
    
    func initCell(_ title:String, _ color:UIColor) {
        backView.backgroundColor = .clear
        //
        labelTitle.text = title
        labelTitle.textColor = .label
        labelTitle.font = UIFont(name: K_Font_R, size: K_FontSize)
        //
        categoryLine.backgroundColor = color
        underline.backgroundColor = .lightGray
    }
}
