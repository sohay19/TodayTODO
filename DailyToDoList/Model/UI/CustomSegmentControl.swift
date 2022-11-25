//
//  CustomSegmentControl.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/07.
//

import Foundation
import UIKit

class CustomSegmentControl : UISegmentedControl {
    private lazy var underlineView: UIView = {
        let width = Int(self.bounds.size.width) / self.numberOfSegments
        let height = 2
        let xPosition = self.selectedSegmentIndex * Int(width)
        let yPosition = self.bounds.size.height - 1
        let frame = CGRect(x: xPosition, y: Int(yPosition), width: width, height: Int(height))
        let view = UIView(frame: frame)
        view.backgroundColor = .label
        self.addSubview(view)
        return view
      }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 언더라인 추가
        let underlineFinalXPosition = (Int(self.bounds.size.width) / self.numberOfSegments) * self.selectedSegmentIndex
            UIView.animate(
              withDuration: 0.1,
              animations: {
                  self.underlineView.frame.origin.x = CGFloat(underlineFinalXPosition)
              })
        //폰트 설정
        let font = UIFont(name: E_Font_B, size: E_FontSize)!
        setTitleTextAttributes([.font:font, .foregroundColor: UIColor.label], for: .selected)
        setTitleTextAttributes([.font:font, .foregroundColor: UIColor.lightGray], for: .normal)
    }
    private func initUI() {
        //배경과 구분선 삭제
        let image = UIImage()
        self.setBackgroundImage(image, for: .normal, barMetrics: .default)
        self.setBackgroundImage(image, for: .selected, barMetrics: .default)
        self.setBackgroundImage(image, for: .highlighted, barMetrics: .default)
        self.setDividerImage(image, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
    }
}
