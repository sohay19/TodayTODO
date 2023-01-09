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
    
    var categoryInfo:String = ""
    var reloadCategory:(() -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        inputTitle.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        initUI()
        loadData()
    }
}

//MARK: - Init
extension AddCategoryViewController {
    private func initUI() {
        // 배경 설정
        let backgroundView = UIImageView(frame: popView.bounds)
        backgroundView.image = UIImage(named: PopBackImage)
        popView.insertSubview(backgroundView, at: 0)
        //그림자
        popView.layer.shadowColor = UIColor.label.withAlphaComponent(0.4).cgColor
        popView.layer.shadowOpacity = 1
        popView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        //
        backView.backgroundColor = .clear
        line1.backgroundColor = .lightGray
        line2.backgroundColor = .lightGray
        //
        labelTitle.textColor = .white
        labelTitle.font = UIFont(name: K_Font_B, size: K_FontSize + 2.0)
        inputTitle.textColor = .white
        inputTitle.font = UIFont(name: K_Font_R, size: K_FontSize)
        inputTitle.backgroundColor = .white.withAlphaComponent(0.2)
        inputTitle.attributedPlaceholder = NSAttributedString(string: "카테고리 명을 입력해주세요", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        inputTitle.textContentType = .nickname
        inputTitle.keyboardType = .default
        inputTitle.clearButtonMode = .whileEditing
        //
        textCounter.textColor = .gray
        textCounter.font = UIFont(name: N_Font, size: N_FontSize - 5.0)
        //
        btnOK.setTitleColor(.white, for: .normal)
        btnCancel.setTitleColor(.white, for: .normal)
        btnOK.titleLabel?.font = UIFont(name: K_Font_R, size: K_FontSize)
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
    private func loadData() {
        if categoryInfo.isEmpty {
            return
        }
        labelTitle.text = "카테고리 수정"
        inputTitle.text = categoryInfo
        colorWell.selectedColor = DataManager.shared.getCategoryColor(categoryInfo)
        textCounter.text = "\(categoryInfo.count)/10"
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
            return
        }
        guard let colorList = color.cgColor.components else {
            return
        }
        if categoryInfo.isEmpty {
            //등록
            let array = DataManager.shared.getCategoryOrder()
            for name in array {
                if name == title {
                    PopupManager.shared.openOkAlert(self, title: "알림", msg: "이미 존재하는 카테고리입니다")
                    return
                }
            }
            addCategory(colorList)
        } else {
            //수정
            if title == categoryInfo && DataManager.shared.getCategoryColor(categoryInfo) == color {
                PopupManager.shared.openOkAlert(self, title: "알림", msg: "변경 된 내용이 없습니다")
            }
            updateCategory(colorList)
        }
        reloadCategory?()
        dismiss(animated: true)
    }
    private func addCategory(_ colorList:[CGFloat]) {
        guard let title = inputTitle.text else {
            return
        }
        let newList = colorList.map{Float($0)}
        let newCategory = CategoryData(title, newList)
        DataManager.shared.addCategory(newCategory)
    }
    private func updateCategory(_ colorList:[CGFloat]) {
        guard let title = inputTitle.text , let origin = DataManager.shared.getCategory(categoryInfo) else {
            return
        }
        let newList = colorList.map{Float($0)}
        let newCategory = CategoryData(origin.primaryKey, title, newList)
        DataManager.shared.updateCategory(newCategory)
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
