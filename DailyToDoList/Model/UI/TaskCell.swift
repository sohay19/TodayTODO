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
    @IBOutlet weak var expandableView: UIView!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var memoView: UITextView!
    @IBOutlet weak var btnArrow: UIImageView!
    @IBOutlet weak var iconClock: UILabel!
    
    var isToday = true
    private var btnArrowSize:CGFloat = 45
    private var btnArrowConstraint:NSLayoutConstraint?
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
            labelTitle.textColor = .label
        }
    }
    
    func initCell() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        mainView.backgroundColor = .clear
        expandableView.backgroundColor = .clear
        memoView.backgroundColor = .clear
        //
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //
        labelTitle.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelTitle.textColor = .label
        labelTime.font = UIFont(name: N_Font, size: N_FontSize)
        labelTime.textColor = .gray
        memoView.font = UIFont(name: K_Font_R, size: K_FontSize)
        memoView.isEditable = false
        memoView.isSelectable = false
        memoView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //
        expandableView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        //
        btnArrow.contentMode = .center
        btnArrow.tintColor = .label
        //
        btnArrow.translatesAutoresizingMaskIntoConstraints = false
        btnArrowConstraint = btnArrow.constraints.first { item in
            return item.identifier == "btnArrowWidth"
        }
    }
    
    func controllMain(_ isOn:Bool) {
        mainView.isHidden = !isOn
        labelTitle.isHidden = !isOn
        btnArrow.isHidden = !isOn
        controllExpandable(!isOn)
        btnArrow.translatesAutoresizingMaskIntoConstraints = false
        btnArrowConstraint?.constant = btnArrowSize
    }
    
    func setMonthCell() {
        controllMain(true)
        btnArrow.isHidden = true
        btnArrow.translatesAutoresizingMaskIntoConstraints = false
        btnArrowConstraint?.constant = 0
    }
    
    private func controllExpandable(_ isOn:Bool) {
        expandableView.isHidden = !isOn
        timeView.isHidden = !isOn
        iconClock.isHidden = !isOn
        memoView.isHidden = !isOn
    }
    
    func inputCell(title:String, memo:String, time:String) {
        labelTitle.text = title
        labelTitle.sizeToFit()
        memoView.text = memo
        labelTime.text = time.isEmpty ? "--:--" : time
        // 알람 아이콘 라벨에 넣기
        let attributedString = NSMutableAttributedString(string: "")
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "stopwatch")?.withTintColor(.label).withConfiguration(UIImage.SymbolConfiguration(scale: .small)).withTintColor(.gray, renderingMode: .alwaysOriginal)
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        iconClock.attributedText = attributedString
    }
    
    func changeArrow(_ isUp:Bool) {
        btnArrow.image = UIImage(systemName: isUp ? "chevron.up" : "chevron.down", withConfiguration: thinConfig)
    }
    
    func taskIsDone(_ isDone:Bool) {
        if isDone {
            removeLine()
            //
            labelTitle.sizeToFit()
            lineView = LineView()
            guard let lineView = lineView else {
                return
            }
            DispatchQueue.main.async { [self] in
                let width = labelTitle.frame.maxX - labelTitle.frame.origin.x
                lineView.frame = CGRect(
                    origin: CGPoint(x: labelTitle.frame.origin.x, y: 0),
                    size: CGSize(width: width, height: frame.height))
                self.addSubview(lineView)
            }
        } else {
            removeLine()
        }
    }
    
    func removeLine() {
        guard let lineView = lineView else {
            return
        }
        lineView.removeFromSuperview()
    }
}
