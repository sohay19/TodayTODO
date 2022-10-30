//
//  PopBackView.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/30.
//

import Foundation
import UIKit


class PopBackView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
}

extension PopBackView {
    private func initView() {
        //모서리 둥글게
        self.layer.cornerRadius = 10
        //그림자
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowRadius = 10
        self.layer.shadowOpacity = 1
    }
}
