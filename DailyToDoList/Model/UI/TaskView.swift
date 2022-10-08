//
//  TaskView.swift
//  dailytimetable
//
//  Created by 소하 on 2022/10/07.
//

import Foundation
import UIKit
import SwiftUI

class TaskView : UIView {
    let timeVeiw = UIView()
    let taskView = UIView()
    let labelTime = UILabel()
    let labelTitle = UILabel()
    let labelMemo = UILabel()
    
    private var taskData:EachTask = EachTask()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        self.timeVeiw.backgroundColor = .systemRed
        self.taskView.backgroundColor = .systemFill
        self.taskView.layer.cornerRadius = 10
        
        timeVeiw.translatesAutoresizingMaskIntoConstraints = false
        taskView.translatesAutoresizingMaskIntoConstraints = false
        
        self.labelTime.textColor = .black
        self.labelTime.font = UIFont.boldSystemFont(ofSize: 12)
        self.labelTime.adjustsFontSizeToFitWidth = true
        
        self.labelTitle.textColor = .black
        self.labelTitle.font = UIFont.systemFont(ofSize: 12)
        self.labelTitle.adjustsFontSizeToFitWidth = true
        
        self.labelMemo.textColor = .black
        self.labelMemo.font = UIFont.systemFont(ofSize: 12)
        self.labelMemo.adjustsFontSizeToFitWidth = true
        
        self.addSubview(timeVeiw)
        timeVeiw.addSubview(labelTime)
        
        self.addSubview(taskView)
        taskView.addSubview(labelTitle)
        taskView.addSubview(labelMemo)
    }
    
    func constraintView(_ data:EachTask, _ parentsWidth:CGFloat) {
        taskData = data
        
        let interval = Calendar.current.dateComponents([.minute], from: Utils.stringTimeToDate(taskData.startTime)!, to: Utils.stringTimeToDate(taskData.endTime)!).minute

        self.frame = CGRect(x: 0, y: 0, width: Int(parentsWidth), height: interval!)
        self.layer.cornerRadius = 50
        
        timeVeiw.frame = CGRect(x: 30, y: 0, width: 30, height: 30)
        taskView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -10).isActive = true
        taskView.heightAnchor.constraint(equalToConstant: CGFloat(interval!)).isActive = true
        
        labelTime.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
        labelTime.text = taskData.startTime.components(separatedBy: ["-","_",":"])[3]
        
        labelTitle.frame = CGRect(x: 3, y: 3, width: taskView.frame.width, height: 12)
        labelTitle.text = taskData.title
        labelMemo.frame = CGRect(x: 3, y: labelTitle.frame.maxY+3, width: taskView.frame.width, height: 12)
        labelMemo.text = taskData.memo
        
    }
}
