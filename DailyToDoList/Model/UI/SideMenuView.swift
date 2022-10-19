//
//  SideMenuView.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/19.
//

import Foundation
import UIKit

class SideMenuView : UIView {
    let menuTable:UITableView = UITableView()
    let btnBackground:UIButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initConstraint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initConstraint()
    }
    
    func initConstraint() {
        self.addSubview(menuTable)
        self.addSubview(btnBackground)
        
        menuTable.translatesAutoresizingMaskIntoConstraints = false
        btnBackground.translatesAutoresizingMaskIntoConstraints = false
        
        menuTable.frame.origin = CGPoint(x: 0, y: 0)
        menuTable.backgroundColor = .black
        
        btnBackground.backgroundColor = .blue
        
        NSLayoutConstraint.activate([
            menuTable.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            menuTable.widthAnchor.constraint(equalToConstant: 150),
            menuTable.heightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.heightAnchor),
            btnBackground.leadingAnchor.constraint(equalTo: menuTable.trailingAnchor),
            btnBackground.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            btnBackground.heightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.heightAnchor)
        ])
    }
}
