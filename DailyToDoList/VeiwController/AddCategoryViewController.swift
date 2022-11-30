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
    @IBOutlet weak var textCounter: UILabel!
    @IBOutlet weak var inputTitle: UITextField!
    @IBOutlet weak var colorWell: UIColorWell!
    //
    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var line1: UIView!
    @IBOutlet weak var line2: UIView!
    
    
    var reloadCategory:(() -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        inputTitle.delegate = self
        //
        initUI()
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
        backgroundView.layer.cornerRadius = 9
        popView.insertSubview(backgroundView, at: 0)
        popView.layer.cornerRadius = 9
        //그림자
        popView.layer.shadowColor = UIColor.label.withAlphaComponent(0.4).cgColor
        popView.layer.shadowRadius = 9
        popView.layer.shadowOpacity = 1
        //
        backView.backgroundColor = .clear
        line1.backgroundColor = .darkGray
        line2.backgroundColor = .darkGray
        //
        labelTitle.textColor = .systemBackground
        labelTitle.font = UIFont(name: K_Font_B, size: K_FontSize + 2.0)
        inputTitle.textColor = .systemBackground
        inputTitle.font = UIFont(name: K_Font_R, size: K_FontSize)
        inputTitle.backgroundColor = .systemBackground.withAlphaComponent(0.1)
        inputTitle.attributedPlaceholder = NSAttributedString(string: "카테고리 명을 입력해주세요", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        inputTitle.textContentType = .nickname
        inputTitle.keyboardType = .default
        inputTitle.clearButtonMode = .whileEditing
        //
        textCounter.textColor = .systemBackground
        textCounter.font = UIFont(name: N_Font, size: N_FontSize - 5.0)
        //
        btnOK.tintColor = .systemBackground
        btnOK.titleLabel?.font = UIFont(name: K_Font_R, size: K_FontSize)
        btnCancel.tintColor = .systemBackground
        btnCancel.titleLabel?.font = UIFont(name: K_Font_R, size: K_FontSize)
        btnBack.tintColor = .clear
        btnBack.backgroundColor = .clear
        //
        colorWell.title = "카테고리 색상"
    }
    //
    private func initFunc() {
        colorWell.addTarget(self, action: #selector(changedColor(_:)), for: .valueChanged)
    }
    @objc func changedColor(_ sender:Any) {
        guard let _ = colorWell.selectedColor else {
            return
        }
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
        let array = DataManager.shared.getCategoryOrder()
        for name in array {
            if name == title {
                PopupManager.shared.openOkAlert(self, title: "알림", msg: "이미 존재하는 카테고리입니다")
            }
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
            dismiss(animated: true)
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
        dismiss(animated: true)
    }
}

//MARK: - TextField
extension AddCategoryViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        let changedText = currentText.replacingCharacters(in: stringRange, with: string)
        textCounter.text = "\(changedText.count)/10"
        return changedText.count < 10
    }
}
