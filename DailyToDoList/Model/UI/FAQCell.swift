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
        //
        self.contentView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        self.contentView.layer.cornerRadius = 5
        self.contentView.layer.borderColor = UIColor.gray.cgColor
        self.contentView.layer.borderWidth = 0.1
        //
        mainView.backgroundColor = .clear
        expandableView.backgroundColor = .clear
        bodyView.backgroundColor = .clear
        //
        labelTitle.font = UIFont(name: K_Font_B, size: K_FontSize)
        labelTitle.textColor = .label
        bodyView.font = UIFont(name: K_Font_R, size: K_FontSize)
        bodyView.isEditable = false
        //
        btnArrow.contentMode = .center
        btnArrow.tintColor = .label
    }
    
    func changeArrow(_ isUp:Bool) {
        btnArrow.image = UIImage(systemName: isUp ? "chevron.up" : "chevron.down", withConfiguration: thinConfig)
    }
    
    func controllMain(_ isOn:Bool) {
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
        bodyView.text = body
    }
}
