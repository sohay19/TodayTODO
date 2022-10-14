//
//  TaskInfoViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/14.
//

import UIKit


class TaskInfoViewController : UIViewController {
    @IBOutlet weak var popView:UIView!
    @IBOutlet weak var inputTitle:UITextField!
    @IBOutlet weak var btnPullCategory:UIButton!
    @IBOutlet weak var pickTaskDate:UIDatePicker!
    //
    @IBOutlet weak var switchRepeat:UISwitch!
    @IBOutlet weak var labelNoRepeat:UILabel!
    @IBOutlet weak var resultView:UIView!
    @IBOutlet weak var labelFirst:UILabel!
    @IBOutlet weak var labelSecond:UILabel!
    @IBOutlet weak var labelThird:UILabel!
    @IBOutlet weak var btnFirst:UIButton!
    @IBOutlet weak var btnSecond:UIButton!
    @IBOutlet weak var pickEndDate:UIDatePicker!
    @IBOutlet weak var labelNoEndDate:UILabel!
    @IBOutlet weak var switchAlarm:UISwitch!
    @IBOutlet weak var pickAlarmTime:UIDatePicker!
    @IBOutlet weak var labelNoAlarm:UILabel!
    @IBOutlet weak var textView:UITextView!
    
    var taskData:EachTask?
    
    //기존 사이즈
    private var resultViewSize:CGSize?
    //constraints
    private var resultViewConstraint:NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //기존 사이즈 저장
        resultViewSize = resultView.frame.size
        //모서리 둥글게
        popView.layer.cornerRadius = 10
        //그림자
        popView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        popView.layer.shadowRadius = 10
        popView.layer.shadowOpacity = 1
        //
        setDefaultView()
        loadUI()
        loadData()
    }
}

extension TaskInfoViewController {
    func setDefaultView() {
        resultView.translatesAutoresizingMaskIntoConstraints = false
        resultViewConstraint = resultView.constraints.first { item in
            return item.identifier == "resultViewHeight"
        }
    }
    func loadData() {
        guard let taskData = taskData else {
            return
        }
        inputTitle.text = taskData.title
        btnPullCategory.setTitle(taskData.category, for: .normal)
        btnPullCategory.backgroundColor = DataManager.shared.getCategoryColor(taskData.category)
        pickTaskDate.date = Utils.dateStringToDate(taskData.taskDay)!
        switch RepeatType(rawValue: taskData.repeatType) {
        case .EveryDay:
            setResult("매일")
            switchRepeat.isOn = true
            labelNoRepeat.text = ""
        case .Eachweek:
            setResult("매 주", taskData.getWeekDay(), "요일")
            switchRepeat.isOn = true
            labelNoRepeat.text = ""
        case .EachMonthOfOnce:
            setResult("매 월", String(taskData.taskDay.split(separator: "-")[2]), "일")
            switchRepeat.isOn = true
            labelNoRepeat.text = ""
        case .EachMonthOfWeek:
            setResult("매 월", String(taskData.monthOfWeek), "주, ", taskData.getWeekDay(), "요일")
            switchRepeat.isOn = true
            labelNoRepeat.text = ""
        case .EachYear:
            setResult("매 년", String(taskData.taskDay.split(separator: "-")[2]), "일")
            switchRepeat.isOn = true
            labelNoRepeat.text = ""
        default:
            setResult()
            switchRepeat.isOn = false
            labelNoRepeat.text = "없음"
        }
        pickEndDate.isHidden = !taskData.isEnd
        labelNoEndDate.isHidden = taskData.isEnd
        if taskData.isEnd {
            pickEndDate.date = Utils.dateStringToDate(taskData.taskEndDate)!
        }
        switchAlarm.isOn = taskData.isAlarm
        pickAlarmTime.isHidden = !taskData.isAlarm
        labelNoAlarm.isHidden = taskData.isAlarm
        if taskData.isAlarm {
            pickAlarmTime.date = Utils.stringToDate("\(taskData.taskDay)_\(taskData.alarmTime)")!
        }
        textView.text = taskData.memo
    }
    
    func loadUI() {
        pickEndDate.isEnabled = false
        controllEditMode(false)
        controllResultView(false)
    }
}

//MARK: - controll
extension TaskInfoViewController {
    //
    func controllEditMode(_ isOn:Bool) {
        guard let taskData = taskData else {
            return
        }
        inputTitle.isEnabled = isOn
        btnPullCategory.isEnabled = isOn
        pickTaskDate.isEnabled = isOn
        switchRepeat.isHidden = !isOn
        if !isOn && RepeatType(rawValue: taskData.repeatType) == .None {
            labelNoRepeat.text = "없음"
        } else {
            labelNoRepeat.text = ""
        }
        switchAlarm.isHidden = !isOn
        pickAlarmTime.isEnabled = isOn
        textView.isEditable = isOn
    }
    //
    func controllResultView(_ isOpen:Bool) {
        if isOpen {
            let anim = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) { [self] in
                resultViewConstraint?.constant = resultViewSize!.height
            }
            anim.startAnimation()
        } else {
            let anim = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) { [self] in
                resultViewConstraint?.constant = 0
                pickEndDate.isHidden = true
            }
            anim.startAnimation()
        }
    }
    //result setting
    func setResult() {
        labelFirst.isHidden = true
        labelSecond.isHidden = true
        labelThird.isHidden = true
        btnFirst.isHidden = true
        btnSecond.isHidden = true
    }
    func setResult(_ thrid:String) {
        labelFirst.isHidden = true
        labelSecond.isHidden = true
        labelThird.isHidden = false
        labelThird.text = thrid
        //
        btnFirst.isHidden = true
        btnSecond.isHidden = true
    }
    func setResult(_ second:String, _ btnsecond:String, _ thrid:String) {
        labelFirst.isHidden = true
        labelSecond.isHidden = false
        labelSecond.text = second
        labelThird.isHidden = false
        labelThird.text = thrid
        //
        btnFirst.isHidden = true
        btnSecond.isHidden = false
        btnSecond.setTitle(btnsecond, for: .normal)
    }
    func setResult(_ first:String, _ btnfirst:String, _ second:String, _ btnsecond:String, _ thrid:String) {
        labelFirst.isHidden = false
        labelFirst.text = first
        labelSecond.isHidden = false
        labelSecond.text = second
        labelThird.isHidden = false
        labelThird.text = thrid
        //
        btnFirst.isHidden = false
        btnFirst.setTitle(btnfirst, for: .normal)
        btnSecond.isHidden = false
        btnSecond.setTitle(btnsecond, for: .normal)
    }
}

//MARK: - Button Event
extension TaskInfoViewController {
    @IBAction func clickModify(_ sender:UIButton) {
        if sender.isSelected {
            controllEditMode(false)
            sender.setTitle("Modify", for: .normal)
            sender.isSelected = false
        } else {
            controllEditMode(true)
            sender.setTitle("Done", for: .normal)
            sender.isSelected = true
        }
    }
}
