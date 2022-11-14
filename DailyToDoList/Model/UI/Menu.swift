//
//  Menu.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/11.
//

import UIKit

class Menu: UIView {
    @IBOutlet weak var menuVeiw: UIStackView!
    //
    @IBOutlet weak var btnTODO: UIButton!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var btnPush: UIButton!
    @IBOutlet weak var btnBackup: UIButton!
    //
    @IBOutlet weak var imgTODO: UIImageView!
    @IBOutlet weak var imgCategory: UIImageView!
    @IBOutlet weak var imgPush: UIImageView!
    @IBOutlet weak var imgBackup: UIImageView!
    //
    @IBOutlet weak var line: UIView!
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func initUI() {
        menuVeiw.axis = .horizontal
        menuVeiw.alignment = .center
        menuVeiw.distribution = .equalSpacing
        menuVeiw.backgroundColor = .clear
        menuVeiw.isLayoutMarginsRelativeArrangement = true
        menuVeiw.layoutMargins = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        //
        imgTODO.image = UIImage(named: Underline_Black)
        imgCategory.image = UIImage(named: Underline_Black)
        imgPush.image = UIImage(named: Underline_Black)
        imgBackup.image = UIImage(named: Underline_Black)
        imgTODO.alpha = 0.8
        imgCategory.alpha = 0.8
        imgPush.alpha = 0.8
        imgBackup.alpha = 0.8
        //
        btnTODO.tintColor = .systemBackground
        btnCategory.tintColor = .systemBackground
        btnPush.tintColor = .systemBackground
        btnBackup.tintColor = .systemBackground
        //
        line.backgroundColor = .systemGray
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
