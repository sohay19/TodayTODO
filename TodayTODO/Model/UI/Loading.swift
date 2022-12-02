//
//  Loading.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/12.
//

import UIKit

class Loading: UIView {
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //
        initailize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //
        initailize()
    }
    
    private func initailize() {
        backgroundColor = .clear
    }
    
    func initUI() {
        indicator.style = .large
        indicator.startAnimating()
    }
}
