//
//  RepeatViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit

class RepeatViewController: UIViewController {
    @IBOutlet weak var popView: UIView!
    //
    @IBOutlet weak var btnPullRepeatType: UIButton!
    //
    @IBOutlet weak var pickEndDate: UIDatePicker!
    //
    @IBOutlet weak var switchEndDate: UISwitch!
    //
    @IBOutlet weak var btnMonthOfWeek: UIButton!
    @IBOutlet weak var btnSunday: UIButton!
    @IBOutlet weak var btnMonday: UIButton!
    @IBOutlet weak var btnTuseday: UIButton!
    @IBOutlet weak var btnWensday: UIButton!
    @IBOutlet weak var btnThursday: UIButton!
    @IBOutlet weak var btnFriday: UIButton!
    @IBOutlet weak var btnSaturday: UIButton!
    
    //
    var pickDate:Date = Date()
    var pickWeekOfMonth = 0
    var pickWeekDay = -1
    //Event
    var clickOk:((RepeatResult) -> Void)?
    var clickCancel:(() -> Void)?
    //color
    let selectedColor = UIColor.systemBlue
    let nonSelectedColor = UIColor.systemFill
    //data
    var repeatType = RepeatType.None
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        //모서리 둥글게
        popView.layer.cornerRadius = 10
        //그림자
        popView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        popView.layer.shadowRadius = 10
        popView.layer.shadowOpacity = 1
        //
        setDefaultUI()
        //
        loadRepeatType()
        loadMonthofWeek()
        //
        SystemManager.shared.openLoading()
    }
}


//MARK: - UI
extension RepeatViewController {
    //
    private func calcDate() {
        //지정된 날짜의 weekOfMonth 및 weekDay확인
        pickWeekOfMonth = Utils.getWeekOfMonth(pickDate)
        pickWeekDay = Utils.getWeekDay(pickDate)
    }
    //Default UI Setting
    private func setDefaultUI() {
        //기본세팅
        switchEndDate.isOn = false
        pickEndDate.isEnabled = false
        btnMonthOfWeek.isEnabled = false
        contorllWeekDay(false)
    }
    //반복 타입 메뉴 로드
    private func loadRepeatType() {
        //
        calcDate()
        //
        var repeatTypeList:[UIAction] = []
        for type in RepeatType.allCases {
            var title = type.rawValue
            switch type {
            case .EveryDay:
                repeatTypeList.append(UIAction(title: title, handler: { _ in
                    self.btnPullRepeatType.setTitle(title, for: .normal)
                    self.repeatType = type
                    //
                    self.setDefaultUI()
                }))
            case .Eachweek:
                repeatTypeList.append(UIAction(title: title, handler: { _ in
                    self.btnPullRepeatType.setTitle(title, for: .normal)
                    self.repeatType = type
                    //
                    self.setDefaultUI()
                    self.contorllWeekDay(true)
                    //
                    self.setWeekDay()
                }))
            case .EachMonthOfOnce:
                title = "매 월 \(Utils.getDay(pickDate))일"
                repeatTypeList.append(UIAction(title: title, handler: { _ in
                    self.btnPullRepeatType.setTitle(title, for: .normal)
                    self.repeatType = type
                    //
                    self.setDefaultUI()
                }))
            case .EachMonthOfWeek:
                title = "매 월 \(Utils.getWeekOfMonthIntKOR(pickWeekOfMonth)) 주, 선택한 요일"
                repeatTypeList.append(UIAction(title: title, handler: { _ in
                    self.btnPullRepeatType.setTitle(title, for: .normal)
                    self.repeatType = type
                    //
                    self.setDefaultUI()
                    self.contorllWeekDay(true)
                    //
                    self.setWeekDay()
                }))
            case .EachYear:
                title = "매 년 \(Utils.getDay(pickDate))일"
                repeatTypeList.append(UIAction(title: title, handler: { _ in
                    self.btnPullRepeatType.setTitle(title, for: .normal)
                    self.repeatType = type
                    //
                    self.setDefaultUI()
                }))
            default:
                repeatTypeList.append(UIAction(title: title, handler: { _ in
                    self.btnPullRepeatType.setTitle(title, for: .normal)
                    self.repeatType = type
                    //
                    self.setDefaultUI()
                    self.contorllWeekDay(true)
                }))
            }
        }
        btnPullRepeatType.menu = UIMenu(title: "반복 주기", image: UIImage(systemName: "plus"), children: repeatTypeList)
    }
    //반복 주기 메뉴 로드
    private func loadMonthofWeek() {
        btnMonthOfWeek.setTitle(Utils.getWeekOfMonthIntKOR(pickWeekOfMonth), for: .normal)
    }
    private func contorllWeekDay(_ isOn:Bool) {
        btnMonday.isEnabled = isOn
        btnTuseday.isEnabled = isOn
        btnWensday.isEnabled = isOn
        btnThursday.isEnabled = isOn
        btnFriday.isEnabled = isOn
        btnSaturday.isEnabled = isOn
        btnSunday.isEnabled = isOn
    }
}

//MARK: - Switch Event
extension RepeatViewController {
    @IBAction func toggleEndDate(_ sender:UISwitch) {
        pickEndDate.isEnabled = sender.isOn
    }
}

//MARK: - Func
extension RepeatViewController {
    //weekDay 알아보기
    private func getWeekDay() -> [Bool] {
        var tmpArr = [Bool](repeating: false, count: 7)
        if btnSunday.isSelected {
            tmpArr[0] = true
        }
        if btnMonday.isSelected {
            tmpArr[1] = true
        }
        if btnTuseday.isSelected {
            tmpArr[2] = true
        }
        if btnWensday.isSelected {
            tmpArr[3] = true
        }
        if btnThursday.isSelected {
            tmpArr[4] = true
        }
        if btnFriday.isSelected {
            tmpArr[5] = true
        }
        if btnSaturday.isSelected {
            tmpArr[6] = true
        }
        
        return tmpArr
    }
    //지정된 요일 버튼 선택
    private func setWeekDay() {
        switch pickWeekDay {
        case 0:
            btnSunday.isSelected = true
            btnSunday.tintColor = selectedColor
        case 1:
            btnMonday.isSelected = true
            btnMonday.tintColor = selectedColor
        case 2:
            btnTuseday.isSelected = true
            btnTuseday.tintColor = selectedColor
        case 3:
            btnWensday.isSelected = true
            btnWensday.tintColor = selectedColor
        case 4:
            btnThursday.isSelected = true
            btnThursday.tintColor = selectedColor
        case 5:
            btnFriday.isSelected = true
            btnFriday.tintColor = selectedColor
        case 6:
            btnSaturday.isSelected = true
            btnSaturday.tintColor = selectedColor
        default:
            break
        }
    }
}

//MARK: - Button Event
extension RepeatViewController {
    //Ok
    @IBAction func clickBtnOk(_ sender: Any) {
        if repeatType == .Eachweek {
            if getWeekDay().filter({ $0 == true }).count == 0 {
                PopupManager.shared.openOkAlert(self, title: "알림", msg: "요일을 하나 이상 선택해주세요.")
                return
            }
        } else if repeatType == .EachMonthOfWeek {
            if getWeekDay().filter({ $0 == true }).count == 0 {
                PopupManager.shared.openOkAlert(self, title: "알림", msg: "요일을 하나 이상 선택해주세요.")
                return
            }
        }
        let result = RepeatResult(repeatType: repeatType, weekDay: getWeekDay(), monthOfWeek: pickWeekOfMonth, isEnd: switchEndDate.isOn, endDate: pickEndDate.date)
        clickOk?(result)
        
        self.dismiss(animated: true)
    }
    //Cancel
    @IBAction func clickBtnCancel(_ sender: Any) {
        clickCancel?()
        self.dismiss(animated: true)
    }
    //요일 버튼
    @IBAction func clickWeekDay(_ sender:UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            sender.tintColor = nonSelectedColor
        } else {
            sender.isSelected = true
            sender.tintColor = selectedColor
        }
    }
    //pickEndDate Change Value
    @IBAction func changeValueEndDate(_ sender:UIDatePicker) {
        //종료일 검토
        if Utils.dateToDateString(pickDate) == Utils.dateToDateString(sender.date) {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "시작일과 종료일이 같을 수 없습니다.")
            pickEndDate.date = Calendar.current.date(byAdding: .day, value: 1, to: pickDate)!
            return
        }
    }
    //
    @IBAction func clickBackground(_ sender:Any) {
        clickCancel?()
        self.dismiss(animated: true)
    }
}
