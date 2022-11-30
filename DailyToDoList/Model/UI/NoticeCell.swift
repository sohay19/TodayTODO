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
        //
        inputTitle.backgroundColor = .systemBackground
        inputTitle.font = UIFont(name: K_Font_B, size: K_FontSize)
        inputTitle.textColor = .label
        textView.backgroundColor = .systemBackground
        textView.layer.cornerRadius = 6
        textView.isEditable = false
        textView.font = UIFont(name: K_Font_R, size: K_FontSize)
        textView.textColor = .label
        textView.isEditable = false
    }
    
    func inputCell(_ title:String, _ body:String) {
        inputTitle.text = title
        textView.text = body
    }
}
