//
//  RepeatTypeContainerViewController.swift
//  dailytimetable
//
//  Created by 소하 on 2022/08/29.
//

import UIKit

class PickerViewController : UIViewController {
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let sheetPresentation = sheetPresentationController {
            sheetPresentation.detents = [.medium()]
            sheetPresentation.prefersScrollingExpandsWhenScrolledToEdge = false
            sheetPresentation.preferredCornerRadius = 0
        }
        pickerView.selectRow(pickerView.selectedRow(inComponent: 0), inComponent: 0, animated: true)
    }
}

//MARK: - Event
extension PickerViewController {
    @IBAction func clickSelect(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

//MARK: - Protocol
extension PickerViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ""
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //
    }
}
