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
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        initUI()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if !editing {
            setBackView(false)
        }
    }
    
    private func initUI() {
        self.selectionStyle = .none
        self.shouldIndentWhileEditing = false
        self.backgroundColor = .clear
        //
        self.contentView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        backView.backgroundColor = .clear
        backView.layer.cornerRadius = 5
        backView.layer.borderWidth = 0.1
        self.contentView.layer.cornerRadius = 5
        self.contentView.layer.borderWidth = 0.1
        //
        setBackView(false)
        //
        labelTitle.font = UIFont(name: K_Font_B, size: K_FontSize + 2.0)
        labelCounter.font = UIFont(name: N_Font, size: N_FontSize)
        labelCounter.tintColor = .label
    }
    
    func inputCell(title:String, counter:Int) {
        labelTitle.text = title
        let color = DataManager.shared.getCategoryColor(title)
        labelTitle.textColor = color
        labelCounter.text = String(counter)
    }
    
    func setBackView(_ isBack:Bool) {
        UIView.transition(with: backView, duration: 0.2) { [self] in
            backView.backgroundColor = isBack ? .lightGray.withAlphaComponent(0.1) : .clear
            backView.layer.borderColor = isBack ? UIColor.gray.cgColor : UIColor.clear.cgColor
        }
        UIView.transition(with: self.contentView, duration: 0.2) { [self] in
            self.contentView.backgroundColor = !isBack ? .lightGray.withAlphaComponent(0.1) : .clear
            self.contentView.layer.borderColor = !isBack ? UIColor.gray.cgColor : UIColor.clear.cgColor
        }
    }
}
