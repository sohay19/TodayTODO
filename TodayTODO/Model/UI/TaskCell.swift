//
//  TaskCell.swift
//  dailytimetable
//
//  Created by 소하 on 2022/10/07.
//

import Foundation
import UIKit

class TaskCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var iconClock: UILabel!
    @IBOutlet weak var categoryLine: UIView!
    
    var isToday = true
    var titleColor:UIColor = .label
    var categoryColor:UIColor = .label
    private var lineView:LineView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        initCell()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        //
        if highlighted {
            labelTitle.textColor = isToday ? .systemIndigo : .defaultPink
        } else {
            labelTitle.textColor = titleColor
        }
    }
    
    func initCell() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        mainView.backgroundColor = .clear
        //
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //
        labelTitle.textColor = titleColor
        labelTime.font = UIFont(name: N_Font, size: N_FontSize)
        labelTime.textColor = .lightGray
        // 알람 아이콘 라벨에 넣기
        let attributedString = NSMutableAttributedString(string: "")
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "clock")?.withTintColor(.label).withConfiguration(UIImage.SymbolConfiguration(scale: .small)).withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        iconClock.attributedText = attributedString
    }
    
    func inputCell(title:String, time:String, color:UIColor) {
        labelTitle.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelTitle.text = title
        timeView.isHidden = time.isEmpty
        labelTime.text = time
        categoryLine.backgroundColor = color
        categoryColor = color
    }
    
    func taskIsDone(_ isDone:Bool) {
//        removeLine()
//        if isDone {
//            lineView = LineView()
//            guard let lineView = lineView else {
//                return
//            }
//            DispatchQueue.main.async { [self] in
//                let width = timeView.frame.maxX - categoryLine.frame.origin.x
//                lineView.frame = CGRect(
//                    origin: CGPoint(x: categoryLine.frame.origin.x, y: 0),
//                    size: CGSize(width: width, height: frame.height))
//                self.addSubview(lineView)
//            }
//        }
        titleColor = isDone ? .lightGray : .label
        categoryLine.backgroundColor = isDone ? .lightGray : categoryColor
    }
    
    func removeLine() {
        guard let lineView = lineView else {
            return
        }
        lineView.removeFromSuperview()
    }
}
