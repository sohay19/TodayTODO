//
//  WeekDayButton.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/30.
//

import Foundation
import UIKit

class WeekDayButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        initUI()
    }
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = isSelected ? .newIndigo : .systemBackground
        }
    }
    //
    private func initUI() {
        self.backgroundColor = .systemBackground
        self.titleLabel?.font = UIFont(name: K_Font_R, size: K_FontSize - 3.0)
        self.titleLabel?.textColor = .darkGray
        self.tintColor = .clear
        self.layer.cornerRadius = 5
    }
}
