//
//  ColorPickerViewController.swift
//  dailytimetable
//
//  Created by 소하 on 2022/09/08.
//

import Foundation
import UIKit

class ColorPickerViewController : UIColorPickerViewController {
    var changeColor:((UIColor) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.delegate = self
        self.title = "카테고리 색상 설정"
    }
}

extension ColorPickerViewController : UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        guard let change = changeColor else {
            return
        }
        change(color)
    }
}
