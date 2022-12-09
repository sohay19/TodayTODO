//
//  Help.swift
//  TodayTODO
//
//  Created by 소하 on 2022/12/09.
//

import UIKit
import Gifu

class Help: UIView {
    @IBOutlet weak var gifImgView: GIFImageView!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnRepeat: UIButton!
    
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
    
    func loadGIF(_ name:String) {
        btnOk.setImage(UIImage(systemName: "xmark")?.withConfiguration(mediumConfig), for: .normal)
        btnOk.tintColor = .label
        btnRepeat.tintColor = .label
        btnRepeat.titleLabel?.font = UIFont(name: K_Font_B, size: K_FontSize)
        gifImgView.animate(withGIFNamed: name)
    }
    
    @IBAction func clickRepeat(_ sender:Any) {
        
    }
    
    @IBAction func clickClose(_ sender:Any) {
        self.removeFromSuperview()
    }
}
