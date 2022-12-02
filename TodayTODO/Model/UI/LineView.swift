//
//  LineView.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/23.
//

import Foundation
import UIKit

class LineView:UIView {
    var shapeLayer:CAShapeLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //
        initUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //
        initUI()
    }
    
    private func initUI() {
        self.backgroundColor = .clear
    }
    
    override func draw(_ rect:CGRect) {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: bounds.minX, y: bounds.midY))
        bezierPath.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY))
        //
        shapeLayer = CAShapeLayer()
        guard let shapeLayer = shapeLayer else {
            return
        }
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.lineWidth = 0.8
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        self.layer.addSublayer(shapeLayer)
        //
//        let animation = CABasicAnimation(keyPath: "strokeEnd")
//        animation.fromValue = 0.0
//        animation.toValue = 1.0
//        animation.duration = 0.1
//        shapeLayer.add(animation, forKey: "drawLineAnimation")
    }
}
