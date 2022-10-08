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
    @IBOutlet weak var btnPullMonthOfWeek: UIButton!
    //
    @IBOutlet weak var pickEndDate: UIDatePicker!
    //
    @IBOutlet weak var switchEndDate: UISwitch!
    //
    @IBOutlet weak var btnSunday: UIButton!
    @IBOutlet weak var btnMonday: UIButton!
    @IBOutlet weak var btnTuseday: UIButton!
    @IBOutlet weak var btnWensday: UIButton!
    @IBOutlet weak var btnThursday: UIButton!
    @IBOutlet weak var btnFriday: UIButton!
    @IBOutlet weak var btnSaturday: UIButton!
    
    //
    var taskDay = ""
    //Event
    var clickOk:((RepeatResult) -> Void)?
    var clickCancel:(() -> Void)?
    //color
    let selectedColor = UIColor.systemBlue
    let nonSelectedColor = UIColor.systemFill
    //data
    var repeatType = RepeatType.None
    var monthOfweek = MonthOfWeek.None
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //모서리 둥글게
        popView.layer.cornerRadius = 10
        //그림자
        popView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        popView.layer.shadowRadius = 10
        popView.layer.shadowOpacity = 1
        //메뉴 로드
        loadRepeatType()
        loadMonthofWeek()
        setDefaultUI()
    }
}


//MARK: - UI
extension RepeatViewController {
    //Default UI Setting
    func setDefaultUI() {
        //기본세팅
        switchEndDate.isOn = false
        pickEndDate.isHidden = true
        btnPullMonthOfWeek.isEnabled = false
        contorllWeekDay(false)
    }
    //반복 타입 메뉴 로드
    func loadRepeatType() {
        var repeatTypeList:[UIAction] = []
        for type in RepeatType.allCases {
            let title = type.rawValue
            repeatTypeList.append(UIAction(title: title, handler: { _ in
                self.btnPullRepeatType.setTitle(title, for: .normal)
                //
                self.repeatType = type
                //
                switch type {
                case .Eachweek:
                    self.setDefaultUI()
                    self.contorllWeekDay(true)
                case .EachMonthOfWeek:
                    self.setDefaultUI()
                    self.btnPullMonthOfWeek.isEnabled = true
                    self.contorllWeekDay(true)
                default:
                    self.setDefaultUI()
                }
            }))
        }
        btnPullRepeatType.menu = UIMenu(title: "반복 주기", image: UIImage(systemName: "plus"), children: repeatTypeList)
    }
    //반복 주기 메뉴 로드
    func loadMonthofWeek() {
        var monthOfWeekList:[UIAction] = []
        for type in MonthOfWeek.allCases {
            let title = String(type.rawValue)
            monthOfWeekList.append(UIAction(title: title, handler: { _ in
                self.btnPullMonthOfWeek.setTitle(title, for: .normal)
                self.monthOfweek = type
                print("\(type.rawValue)")
            }))
        }
        btnPullMonthOfWeek.menu = UIMenu(title: "주 선택", image: UIImage(systemName: "plus"), children: monthOfWeekList)
    }
    func contorllWeekDay(_ isOn:Bool) {
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
        pickEndDate.isHidden = !sender.isOn
    }
}

//MARK: - Func
extension RepeatViewController {
    //weekDay 알아보기
    func getWeekDay() -> [Bool] {
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
}

//MARK: - Button Event
extension RepeatViewController {
    //Ok
    @IBAction func clickBtnOk(_ sender: Any) {
        switch repeatType {
        case .Eachweek:
            if getWeekDay().filter({ $0 == true }).count == 0 {
                PopupManager.shared.openOkAlert(self, title: "알림", msg: "요일을 하나 이상 선택해주세요.")
                return
            }
        case .EachMonthOfWeek:
            if monthOfweek == MonthOfWeek.None {
                PopupManager.shared.openOkAlert(self, title: "알림", msg: "주를 선택해주세요.")
                return
            }
            if getWeekDay().filter({ $0 == true }).count == 0 {
                PopupManager.shared.openOkAlert(self, title: "알림", msg: "요일을 하나 이상 선택해주세요.")
                return
            }
        default:
            print("ok")
        }
        if switchEndDate.isOn && Utils.dateToString(pickEndDate.date) == taskDay {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "시작일과 종료일이 같을 수 없습니다.")
            return
        }
        let result = RepeatResult(repeatType: repeatType, weekDay: getWeekDay(), monthOfWeek: monthOfweek, isEnd: switchEndDate.isOn, endDate: pickEndDate.date)
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
}
