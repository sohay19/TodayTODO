//
//  NoticeViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/29.
//

import Foundation
import UIKit

class NoticeViewController : UIViewController {
    @IBOutlet weak var line:UIView!
    //
    @IBOutlet weak var labelTitle:UILabel!
    @IBOutlet weak var btnBack: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

//MARK: - init
extension NoticeViewController {
    private func initUI() {
        // 배경 설정
        let backgroundView = UIImageView(frame: UIScreen.main.bounds)
        backgroundView.image = UIImage(named: BackgroundImage)
        view.insertSubview(backgroundView, at: 0)
        line.backgroundColor = .label
        //
        labelTitle.font = UIFont(name: E_Font_B, size: E_FontSize)
        //
        btnBack.setImage(UIImage(systemName: "chevron.backward", withConfiguration: mediumConfig), for: .normal)
        btnBack.tintColor = .label
    }
}

//MARK: - Button Event
extension NoticeViewController {
    @IBAction func clickBack(_ sender:Any) {
        guard let navigationController = self.navigationController as? CustomNavigationController else { return }
        navigationController.popViewController()
    }
}
