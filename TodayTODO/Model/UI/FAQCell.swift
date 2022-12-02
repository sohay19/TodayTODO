//
//  FAQCell.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/12/01.
//

import UIKit

class FAQCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var expandableView: UIView!
    @IBOutlet weak var bodyView: UITextView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var btnArrow: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        //
        initCell()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        //
        labelTitle.textColor = highlighted ? .systemIndigo :.label
    }
    
    func initCell() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.separatorInset = UIEdgeInsets(top: 0, left: 9, bottom: 0, right: 9)
        self.contentView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        self.contentView.layer.cornerRadius = 5
        //
        mainView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        mainView.layer.cornerRadius = 5
        mainView.layer.borderColor = UIColor.gray.cgColor
        mainView.layer.borderWidth = 0.1
        expandableView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        expandableView.layer.cornerRadius = 5
        //
        mainView.backgroundColor = .clear
        expandableView.backgroundColor = .clear
        bodyView.backgroundColor = .clear
        //
        labelTitle.font = UIFont(name: K_Font_B, size: K_FontSize)
        labelTitle.textColor = .label
        bodyView.layer.cornerRadius = 5
        bodyView.layer.borderColor = UIColor.gray.cgColor
        bodyView.layer.borderWidth = 0.1
        bodyView.contentInset = UIEdgeInsets(top: 9, left: 18, bottom: 9, right: 18)
        bodyView.isEditable = false
        //
        btnArrow.contentMode = .center
        btnArrow.tintColor = .label
    }
    
    func changeArrow(_ isUp:Bool) {
        btnArrow.image = UIImage(systemName: isUp ? "chevron.up" : "chevron.down", withConfiguration: thinConfig)
    }
    
    func controllMain(_ isOn:Bool) {
        self.contentView.backgroundColor = isOn ? .lightGray.withAlphaComponent(0.1) : .clear
        mainView.isHidden = !isOn
        labelTitle.isHidden = !isOn
        btnArrow.isHidden = !isOn
        controllExpandable(!isOn)
    }
    
    private func controllExpandable(_ isOn:Bool) {
        expandableView.isHidden = !isOn
        bodyView.isHidden = !isOn
    }
    
    func inputCell(_ title:String, _ body:String) {
        labelTitle.text = title
        // 글자 변환
        if let font = UIFont(name: K_Font_R, size: K_FontSize) {
            bodyView.setLineSpacing(body, font: font)
        }
    }
}
