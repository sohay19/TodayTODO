//
//  CustomSegmentControl.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/07.
//

import Foundation
import UIKit

class CustomSegmentControl : UISegmentedControl {
    override func layoutSubviews() {
        super.layoutSubviews()
        //
        layer.cornerRadius = 0
        //
        layer.backgroundColor = UIColor.clear.cgColor
        //
        selectedSegmentTintColor = .label
        //
        let font = UIFont(name: MenuENGFont, size: MenuENGFontSize)!
        setTitleTextAttributes([.font:font, .foregroundColor: UIColor.systemBackground], for: .selected)
        setTitleTextAttributes([.font:font, .foregroundColor: UIColor.secondaryLabel], for: .normal)
    }
}
