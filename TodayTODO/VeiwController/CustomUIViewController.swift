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
    @IBOutlet weak var itemView1:UIView!
    @IBOutlet weak var itemView2:UIView!
    @IBOutlet weak var itemView3:UIView!
    @IBOutlet weak var stackView:UIStackView!
    @IBOutlet weak var imgTheme1:UIImageView!
    @IBOutlet weak var imgTheme2:UIImageView!
    @IBOutlet weak var imgTheme3:UIImageView!
    @IBOutlet weak var labelTheme1:UILabel!
    @IBOutlet weak var labelTheme2:UILabel!
    @IBOutlet weak var labelTheme3:UILabel!
    
    
    var isRefresh = false
    let fontList:[FontType] = [ .Barunpen, .SquareNeo, .SquareRound]
    var imgList:[UIImageView] = []
    var labelList:[UILabel] = []
    var viewList:[UIView] = []
    var backImgList:[String] = [WhiteBackImage, BlackBackImage, ""]
    let backgroundView = UIImageView(frame: UIScreen.main.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        tableView.delegate = self
        tableView.dataSource = self
        //
        viewList.append(itemView1)
        viewList.append(itemView2)
        viewList.append(itemView3)
        imgList.append(imgTheme1)
        imgList.append(imgTheme2)
        imgList.append(imgTheme3)
        labelList.append(labelTheme1)
        labelList.append(labelTheme2)
        labelList.append(labelTheme3)
        //
        view.insertSubview(backgroundView, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SystemManager.shared.openLoading()
        //
        initUI()
    }
}

extension CustomUIViewController {
    private func initUI() {
        // 배경 설정
        backgroundView.image = UIImage(named: BackgroundImage)
        line.backgroundColor = .label
        //
        labelTitle.font = UIFont(name: E_Font_B, size: E_FontSize)
        imgArrow.tintColor = .label
        btnFont.backgroundColor = .lightGray.withAlphaComponent(0.1)
        btnFont.layer.cornerRadius = 10
        btnFont.layer.borderWidth = 0.5
        btnFont.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.borderWidth = 0.5
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.separatorColor = .gray
        tableView.separatorInsetReference = .fromCellEdges
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        tableView.backgroundColor = .clear
        //
        for item in viewList {
            item.backgroundColor = .clear
        }
        controllTableView(false)
        //
        for (i, img) in imgList.enumerated() {
            img.layer.borderWidth = 0.5
            img.layer.borderColor = UIColor.lightGray.cgColor
            img.contentMode = .scaleToFill
            let backImg = backImgList[i]
            img.image = UIImage(named: backImg)
            //
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickTheme))
            tapGesture.name = backImg
            img.addGestureRecognizer(tapGesture)
            img.isUserInteractionEnabled = true
        }
        for (i, label) in labelList.enumerated() {
            label.text = ""
            let theme = DataManager.shared.getTheme()
            if backImgList[i] == theme {
                let image = UIImage(systemName: "checkmark")?.withTintColor(.label, renderingMode: .alwaysTemplate)
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = image
                let imageString = NSAttributedString(attachment: imageAttachment)
                let attributedString = NSMutableAttributedString(attributedString: imageString)
                label.attributedText = attributedString
            } else {
                label.attributedText = nil
            }
        }
        //
        labelFont.font = UIFont(name: K_Font_B, size: K_FontSize + 2.0)
        labelFont.textColor = .label
        labelTheme.font = UIFont(name: K_Font_B, size: K_FontSize + 2.0)
        labelTheme.textColor = .label
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
        //
        if isRefresh {
            endAppearanceTransition()
            isRefresh = false
        }
        SystemManager.shared.closeLoading()
    }
    
    @objc private func clickTheme(_ gesture:UITapGestureRecognizer) {
        guard let backImg = gesture.name else { return }
        DataManager.shared.setTheme(backImg)
        //
        BackgroundImage = backImg
        refresh()
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
