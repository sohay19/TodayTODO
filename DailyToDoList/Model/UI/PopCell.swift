//
//  PopCell.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/26.
//

import UIKit

class PopCell: UITableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        initUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func initUI() {
        // 간격
        self.contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 9, left: 0, bottom: 9, right: 0))
        // 배경
        self.backgroundColor = .systemBackground
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = 0.5
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        // 선택 시 배경
        let backgroundView = UIView(frame: self.bounds)
        backgroundView.backgroundColor = .defaultPink!.withAlphaComponent(0.3)
        backgroundView.clipsToBounds = true
        self.selectedBackgroundView = backgroundView
        //
        labelTitle.font = UIFont(name: K_Font_B, size: K_FontSize)
    }
    
    func inputCell(_ title:String) {
        labelTitle.text = title
        labelTitle.textColor = DataManager.shared.getCategoryColor(title)
    }
}
