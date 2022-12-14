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
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var underline: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        initUI()
    }
    
    private func initUI() {
        self.backgroundColor = .clear
    }
    
    func initCell(title:String, date:String) {
        backView.backgroundColor = .clear
        //
        labelTitle.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelTitle.textColor = .label
        labelDate.font = UIFont(name: K_Font_R, size: K_FontSize - 2.0)
        labelDate.textColor = .lightGray
        //
        labelTitle.text = title
        labelDate.text = date
        //
        underline.backgroundColor = .gray.withAlphaComponent(0.3)
    }
}
