//
//  Menu.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/11.
//

import UIKit

class Menu: UIStackView {
    @IBOutlet weak var btnTODO: UIButton!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var btnPush: UIButton!
    @IBOutlet weak var btnBackup: UIButton!
    
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        //
        initailize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //
        initailize()
    }
    
    private func initailize() {
        axis = .horizontal
        alignment = .center
        distribution = .equalSpacing
        backgroundColor = .clear
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
    }
    
    func initUI(_ color:UIColor) {
        btnTODO.tintColor = color
        btnCategory.tintColor = color
        btnPush.tintColor = color
        btnBackup.tintColor = color
    }
}

extension Menu {
    @IBAction func clickTODO(_ sender:Any) {
        SystemManager.shared.moveMain()
    }
    @IBAction func clickPush(_ sender:Any) {
        SystemManager.shared.movePush()
    }
    @IBAction func clickBackup(_ sender:Any) {
        SystemManager.shared.moveBackup()
    }
}
