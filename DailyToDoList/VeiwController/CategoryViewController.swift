//
//  CategoryViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit

class CategoryViewController: UIViewController {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        initUI()
        initCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        SystemManager.shared.closeLoading()
    }
}

//MARK: - Init
extension CategoryViewController {
    private func initUI() {
        labelTitle.font = UIFont(name: E_Font_E, size: MenuFontSize)
        labelTitle.textColor = .label
        //
        btnEdit.setImage(UIImage(systemName: "scissors"), for: .normal)
        btnEdit.tintColor = .label
    }
    
    private func initCell() {
        
    }
}

//MARK: - Button Event
extension CategoryViewController {
    @IBAction func clickEdit(_ sender:Any) {
        
    }
}

