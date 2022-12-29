//
//  NoticeCell.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/12/01.
//

import Foundation
import UIKit

class NoticeCell: UITableViewCell {
    @IBOutlet weak var inputTitle: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        initUI()
    }
    
    private func initUI() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.separatorInset = UIEdgeInsets(top: 0, left: 9, bottom: 0, right: 9)
        //
        inputTitle.backgroundColor = .lightGray.withAlphaComponent(0.1)
        inputTitle.layer.cornerRadius = 5
        inputTitle.layer.borderWidth = 0.1
        inputTitle.layer.borderColor = UIColor.gray.cgColor
        inputTitle.textColor = .label
        inputTitle.isEnabled = false
        //
        textView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 0.1
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.isEditable = false
    }
    
    func inputCell(_ title:String, _ body:String) {
        inputTitle.font = UIFont(name: K_Font_B, size: K_FontSize)
        inputTitle.text = title
        // 글자 변환
        if let font = UIFont(name: K_Font_R, size: K_FontSize) {
            textView.setLineSpacing(body, font: font, color: .label, align: .left)
        }
    }
}
