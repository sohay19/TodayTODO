//
//  CustomUIViewController.swift
//  TodayTODO
//
//  Created by 소하 on 2022/12/29.
//

import Foundation
import UIKit

class CustomUIViewController : UIViewController {
    @IBOutlet weak var labelTitle:UILabel!
    @IBOutlet weak var labelTheme:UILabel!
    @IBOutlet weak var labelFont:UILabel!
    @IBOutlet weak var line:UIView!
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var btnFont:UIButton!
    @IBOutlet weak var btnBackFont:UIButton!
    @IBOutlet weak var imgArrow:UIImageView!
    @IBOutlet weak var tableView:UITableView!
    
    var isRefresh = false
    let fontList:[FontType] = [ .Barunpen, .SquareNeo, .SquareRound]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        tableView.delegate = self
        tableView.dataSource = self
        //
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        setUI()
        if isRefresh {
            endAppearanceTransition()
            isRefresh = false
        }
    }
}

extension CustomUIViewController {
    private func initUI() {
        // 배경 설정
        let backgroundView = UIImageView(frame: UIScreen.main.bounds)
        backgroundView.image = UIImage(named: BackgroundImage)
        view.insertSubview(backgroundView, at: 0)
        line.backgroundColor = .label
        //
        labelTitle.font = UIFont(name: E_Font_B, size: E_FontSize)
        imgArrow.tintColor = .label
        btnFont.backgroundColor = .lightGray.withAlphaComponent(0.1)
        btnFont.layer.cornerRadius = 10
        tableView.layer.borderWidth = 0.5
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.separatorColor = .gray
        tableView.separatorInsetReference = .fromCellEdges
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        tableView.backgroundColor = .clear
    }
    
    private func setUI() {
        controllTableView(false)
        //
        labelFont.font = UIFont(name: K_Font_B, size: K_FontSize + 2.0)
        labelFont.textColor = .label
        var title = ""
        switch DataManager.shared.getFont() {
        case .Barunpen:
            title = "나눔바른펜"
        case .SquareNeo:
            title = "나눔스퀘어네오"
        case .SquareRound:
            title = "나눔스퀘어라운드"
        }
        btnFont.titleLabel?.font = UIFont(name: K_Font_R, size: K_FontSize)
        btnFont.setTitle(title, for: .normal)
        btnFont.setTitleColor(.label, for: .normal)
    }
    
    private func changeFont(_ type:FontType) {
        DataManager.shared.setFont(type)
        switch type {
        case .Barunpen:
            K_Font_B = NanumBarunpen_B
            K_Font_R = NanumBarunpen_R
        case .SquareNeo:
            K_Font_B = NanumSquareNeo_B
            K_Font_R = NanumSquareNeo_B
        case .SquareRound:
            K_Font_B = NanumSquareRound_B
            K_Font_R = NanumSquareRound_R
        }
    }
    
    private func refresh() {
        isRefresh = true
        beginAppearanceTransition(true, animated: true)
    }
    
    private func controllTableView(_ isOn:Bool) {
        tableView.isHidden = !isOn
        btnBackFont.isHidden = !isOn
    }
}

//MARK: - Button Event
extension CustomUIViewController {
    @IBAction func clickFont(_ sender:Any) {
        controllTableView(true)
    }
    
    @IBAction func clickBackFont(_ sender:Any) {
        controllTableView(false)
    }
    
    @IBAction func clickBack(_ sender:Any) {
        guard let navigationController = self.navigationController as? CustomNavigationController else { return }
        navigationController.popViewController()
    }
}

//MARK: - TableView
extension CustomUIViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fontList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FontCell", for: indexPath) as? FontCell else {
            return UITableViewCell()
        }
        cell.inputCell(fontList[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DataManager.shared.setFont(fontList[indexPath.row])
        //
        SystemManager.shared.setFont()
        refresh()
    }
}
