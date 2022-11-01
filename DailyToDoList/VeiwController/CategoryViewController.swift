//
//  CategoryViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit

class CategoryViewController: UIViewController {
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var btnColorView: UIView!
    @IBOutlet weak var inputTitle: UITextField!
    
    //
    var reloadCategory:(() -> Void)?
    //
    var btnColor:UIColorWell?
    //
    var colorController:ColorPickerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        if let sheetPresentationController = sheetPresentationController {
            sheetPresentationController.detents = [.large()]
            sheetPresentationController.preferredCornerRadius = 30
            sheetPresentationController.prefersGrabberVisible = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        //
        guard let colorWell = self.btnColorView as? UIColorWell else {
            return
        }
        colorWell.isEnabled = false
        btnColor = colorWell
        //
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            SystemManager.shared.closeLoading()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let colorVC = segue.destination as? ColorPickerViewController else { return }
        colorVC.changeColor = changeBtnColor(_:)
    }
}


//MARK: - Button Event
extension CategoryViewController {
    @IBAction func clickOk(_ sender: Any) {
        guard let button = btnColor else {
            return
        }
        guard let color = button.selectedColor else {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "색상을 선택해주세요")
            return
        }
        guard let list = color.cgColor.components, let title = inputTitle.text else {
            return
        }
        if title.isEmpty {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "카테고리 명을 입력해주세요")
        } else {
            let newList = list.map{Float($0)}
            let newCategory = CategoryData(title, newList)
            RealmManager.shared.addCategory(newCategory)
            guard let reload = self.reloadCategory else {
                return
            }
            reload()
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
    }
}

//MARK: - Func
extension CategoryViewController {
    func changeBtnColor(_ color:UIColor) {
        guard let button = btnColor else {
            return
        }
        button.selectedColor = color
    }
}
