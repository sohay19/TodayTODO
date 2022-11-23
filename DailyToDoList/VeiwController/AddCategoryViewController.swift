//
//  AddCategoryViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/22.
//

import Foundation
import UIKit

class AddCategoryViewController: UIViewController {
    @IBOutlet var backView: UIView!
    @IBOutlet weak var popView: UIView!
    //
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var inputTitle: UITextField!
    @IBOutlet weak var colorWell: UIColorWell!
    //
    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    
    var reloadCategory:(() -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        initUI()
        initGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

//MARK: - Init
extension AddCategoryViewController {
    private func initUI() {
        // 배경 설정
        let backgroundView = UIImageView(frame: popView.bounds)
        backgroundView.image = UIImage(named: BlackBackImage)
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 10
        popView.insertSubview(backgroundView, at: 0)
        popView.layer.cornerRadius = 10
        backView.backgroundColor = .clear
        //
        labelTitle.textColor = .systemBackground
        labelTitle.font = UIFont(name: K_Font_B, size: K_FontSize)
        inputTitle.textColor = .systemBackground
        inputTitle.font = UIFont(name: K_Font_R, size: K_FontSize)
        inputTitle.attributedPlaceholder = NSAttributedString(string: "카테고리 명을 입력해주세요", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        inputTitle.textContentType = .nickname
        inputTitle.keyboardType = .default
        //
        btnOK.tintColor = .systemBackground
        btnOK.titleLabel?.font = UIFont(name: K_Font_R, size: K_FontSize)
        btnCancel.tintColor = .systemBackground
        btnCancel.titleLabel?.font = UIFont(name: K_Font_R, size: K_FontSize)
        //
        colorWell.title = "카테고리 색상"
    }
    //
    private func initGesture() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(exit))
        tapGesture.numberOfTapsRequired = 1
        backView.addGestureRecognizer(tapGesture)
    }
    //
    private func initFunc() {
        colorWell.addTarget(self, action: #selector(changedColor(_:)), for: .valueChanged)
    }
    @objc func changedColor(_ sender:Any) {
        guard let color = colorWell.selectedColor else {
            return
        }
        print(color)
    }
}


//MARK: - Button Event
extension AddCategoryViewController {
    @IBAction func clickOk(_ sender: Any) {
        guard let color = colorWell.selectedColor else {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "색상을 선택해주세요")
            return
        }
        guard let title = inputTitle.text else {
            return
        }
        if title.isEmpty {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "카테고리 명을 입력해주세요")
        } else {
            guard let colorList = color.cgColor.components else {
                return
            }
            addCategory(colorList)
            guard let reload = self.reloadCategory else {
                return
            }
            reload()
            exit()
        }
    }
    private func addCategory(_ colorList:[CGFloat]) {
        guard let title = inputTitle.text else {
            return
        }
        let newList = colorList.map{Float($0)}
        let newCategory = CategoryData(title, newList)
        DataManager.shared.addCategory(newCategory)
    }
    @IBAction func clickCancel(_ sender: Any) {
        exit()
    }
    @objc private func exit() {
        dismiss(animated: true)
    }
}
