//
//  VersionViewController.swift
//  TodayTODO
//
//  Created by 소하 on 2022/12/09.
//

import Foundation
import UIKit

class VersionViewController: UIViewController {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var btnBack: UIButton!
    
    var isRefresh = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        loadData()
    }
}

//MARK: - Func
extension VersionViewController {
    private func initUI() {
        // 배경 설정
        let backgroundView = UIImageView(frame: UIScreen.main.bounds)
        backgroundView.image = UIImage(named: BackgroundImage)
        view.insertSubview(backgroundView, at: 0)
        line.backgroundColor = .label
        //
        labelTitle.font = UIFont(name: E_Font_B, size: E_FontSize)
        labelInfo.textColor = .label
        labelInfo.font = UIFont(name: N_Font, size: N_FontSize + 3.0)
        //
        imgView.layer.shadowColor = UIColor.gray.cgColor
        imgView.layer.shadowOpacity = 1
        imgView.layer.shadowOffset = CGSize(width: 1, height: 3)
        //
        btnBack.setImage(UIImage(systemName: "chevron.backward", withConfiguration: mediumConfig), for: .normal)
        btnBack.tintColor = .label
    }
    @objc private func changeSegment(_ sender:Any) {
        refresh()
    }
    private func refresh() {
        isRefresh = true
        beginAppearanceTransition(true, animated: true)
    }
    //
    func loadData() {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String,
              let build = dictionary["CFBundleVersion"] as? String
        else { return }
        
        imgView.image = Utils.getAppIcon()
        labelInfo.text = "Ver. \(version) (\(build))"
        
        SystemManager.shared.closeLoading()
        if isRefresh {
            endAppearanceTransition()
            isRefresh = false
        }
    }
}

//MARK: - Button Event
extension VersionViewController {
    @IBAction func clickBack(_ sender:Any) {
        guard let navigationController = self.navigationController as? CustomNavigationController else { return }
        navigationController.popViewController()
    }
}
