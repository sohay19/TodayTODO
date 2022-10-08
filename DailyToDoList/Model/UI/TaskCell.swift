//
//  TaskCell.swift
//  dailytimetable
//
//  Created by 소하 on 2022/10/07.
//

import Foundation
import UIKit

class TaskCell: UITableViewCell {
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var taskView: TaskView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func commonInit() {
        taskView.labelTitle.text = "title"
        taskView.labelMemo.text = "memo"
    }
}
