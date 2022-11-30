//
//  RepeatViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit

class RepeatViewController: UIViewController {
    @IBOutlet weak var popView: UIView!
    @IBOutlet weak var line1: UIView!
    @IBOutlet weak var line2: UIView!
    //
    @IBOutlet weak var labelRepeat: UILabel!
    @IBOutlet weak var labelEndDate: UILabel!
    @IBOutlet weak var labelWeekDay: UILabel!
    //
    @IBOutlet weak var btnPullRepeatType: UIButton!
    @IBOutlet weak var pickEndDate: UIDatePicker!
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
    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    //
    var pickDate:Date = Date()
    var pickWeekOfMonth = 0
    var pickWeekDay = -1
    //Event
    var clickOk:((RepeatResult) -> Void)?
    var clickCancel:(() -> Void)?
    //data
    var repeatType = RepeatType.None
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        loadRepeatType()
    }
}

//MARK: - UI
extension RepeatViewController {
    private func initUI() {
        self.view.backgroundColor = .clear
        // 배경 설정
        let backgroundView = UIImageView(frame: popView.bounds)
        backgroundView.image = UIImage(named: BlackBackImage)
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 9
        popView.insertSubview(backgroundView, at: 0)
        //모서리 둥글게
        popView.layer.cornerRadius = 9
        //그림자
        popView.layer.shadowColor = UIColor.label.withAlphaComponent(0.4).cgColor
        popView.layer.shadowRadius = 9
        popView.layer.shadowOpacity = 1
        //
        line1.backgroundColor = .darkGray
        line2.backgroundColor = .darkGray
        //
        labelRepeat.textColor = .systemBackground
        labelRepeat.font = UIFont(name: K_Font_B, size: K_FontSize)
        labelEndDate.textColor = .systemBackground
        labelEndDate.font = UIFont(name: K_Font_B, size: K_FontSize)
        labelWeekDay.textColor = .systemBackground
        labelWeekDay.font = UIFont(name: K_Font_B, size: K_FontSize)
        //
        btnPullRepeatType.tintColor = .label
        btnPullRepeatType.backgroundColor = .systemBackground
        btnPullRepeatType.titleLabel?.font = UIFont(name: K_Font_R, size: K_FontSize)
        btnPullRepeatType.layer.cornerRadius = 5
        pickEndDate.overrideUserInterfaceStyle = .dark
        switchEndDate.onTintColor = .systemIndigo
        //
        btnOK.tintColor = .systemBackground
        btnOK.titleLabel?.font = UIFont(name: K_Font_R, size: K_FontSize)
        btnCancel.tintColor = .systemBackground
        btnCancel.titleLabel?.font = UIFont(name: K_Font_R, size: K_FontSize)
        btnBack.tintColor = .clear
        btnBack.backgroundColor = .clear
    }
    //지정된 날짜의 weekOfMonth 및 weekDay확인
    private func calcDate() {
        let weekOfMonth = Utils.getWeekOfMonth(pickDate)
        pickWeekOfMonth = weekOfMonth >= 5 ? -1 : weekOfMonth
        pickWeekDay = Utils.getWeekDay(pickDate)
    }
    //Default UI Setting
    private func setDefaultUI() {
        //기본세팅
        switchEndDate.isOn = false
        pickEndDate.isEnabled = false
        let minDate = Calendar.current.date(byAdding: .day, value: +1, to: pickDate)!
        pickEndDate.setDate(minDate, animated: true)
        pickEndDate.minimumDate = minDate
        contorllWeekDay(false)
    }
    //반복 타입 메뉴 로드
    private func loadRepeatType() {
        //
        calcDate()
        //
        var actionList:[UIAction] = []
        for type in RepeatType.allCases {
            var title = type.rawValue
            //
            switch type {
            case .None:
                actionList.append(UIAction(title: title, handler: { [self] _ in
                    repeatType = type
                    setDefaultUI()
                    btnPullRepeatType.setTitle(title, for: .normal)
                    //
                    contorllWeekDay(false)
                    switchEndDate.isEnabled = false
                }))
            case .EveryDay:
                actionList.append(UIAction(title: title, handler: { [self] _ in
                    repeatType = type
                    setDefaultUI()
                    btnPullRepeatType.setTitle(title, for: .normal)
                    //
                    switchEndDate.isEnabled = true
                }))
            case .Eachweek:
                actionList.append(UIAction(title: title, handler: { [self] _ in
                    repeatType = type
                    setDefaultUI()
                    btnPullRepeatType.setTitle(title, for: .normal)
                    //
                    contorllWeekDay(true)
                    setWeekDay()
                    switchEndDate.isEnabled = true
                }))
            case .EachOnceOfMonth:
                title = "매 월 \(Utils.getDay(pickDate))일"
                actionList.append(UIAction(title: title, handler: { [self] _ in
                    repeatType = type
                    setDefaultUI()
                    btnPullRepeatType.setTitle(title, for: .normal)
                    //
                    switchEndDate.isEnabled = true
                }))
            case .EachWeekOfMonth:
                title = "매 월 \(Utils.getWeekOfMonthInKOR(pickWeekOfMonth)) 주, 선택한 요일"
                actionList.append(UIAction(title: title, handler: { [self] _ in
                    repeatType = type
                    setDefaultUI()
                    btnPullRepeatType.setTitle(title, for: .normal)
                    //
                    contorllWeekDay(true)
                    setWeekDay()
                    switchEndDate.isEnabled = true
                }))
            case .EachYear:
                title = "매 년 \(Utils.getDay(pickDate))일"
                actionList.append(UIAction(title: title, handler: { [self] _ in
                    repeatType = type
                    setDefaultUI()
                    btnPullRepeatType.setTitle(title, for: .normal)
                    //
                    switchEndDate.isEnabled = true
                }))
            }
        }
        btnPullRepeatType.menu = UIMenu(title: "반복 주기", image: UIImage(systemName: "plus"), children: actionList)
        btnPullRepeatType.sendAction(actionList[0])
        //
        SystemManager.shared.closeLoading()
    }
    private func contorllWeekDay(_ isOn:Bool) {
        btnSunday.isEnabled = isOn
        btnSunday.backgroundColor = isOn ? .systemBackground : .gray
        btnMonday.isEnabled = isOn
        btnMonday.backgroundColor = isOn ? .systemBackground : .gray
        btnTuseday.isEnabled = isOn
        btnTuseday.backgroundColor = isOn ? .systemBackground : .gray
        btnWensday.isEnabled = isOn
        btnWensday.backgroundColor = isOn ? .systemBackground : .gray
        btnThursday.isEnabled = isOn
        btnThursday.backgroundColor = isOn ? .systemBackground : .gray
        btnFriday.isEnabled = isOn
        btnFriday.backgroundColor = isOn ? .systemBackground : .gray
        btnSaturday.isEnabled = isOn
        btnSaturday.backgroundColor = isOn ? .systemBackground : .gray
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
        case 1:
            btnMonday.isSelected = true
        case 2:
            btnTuseday.isSelected = true
        case 3:
            btnWensday.isSelected = true
        case 4:
            btnThursday.isSelected = true
        case 5:
            btnFriday.isSelected = true
        case 6:
            btnSaturday.isSelected = true
        default:
            break
        }
    }
}

//MARK: - Button Event
extension RepeatViewController {
    //Ok
    @IBAction func clickBtnOk(_ sender: Any) {
        switch repeatType {
        case .None:
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "반복 주기를 선택하세요")
            return
        case .Eachweek:
            if getWeekDay().filter({ $0 == true }).count == 0 {
                PopupManager.shared.openOkAlert(self, title: "알림", msg: "요일을 하나 이상 선택해주세요.")
                return
            }
        case .EachWeekOfMonth:
            if getWeekDay().filter({ $0 == true }).count == 0 {
                PopupManager.shared.openOkAlert(self, title: "알림", msg: "요일을 하나 이상 선택해주세요.")
                return
            }
        default:
            ()
        }
        let result = RepeatResult(repeatType: repeatType, weekDay: getWeekDay(), weekOfMonth: pickWeekOfMonth, isEnd: switchEndDate.isOn, endDate: pickEndDate.date)
        clickOk?(result)
        dismiss(animated: true)
    }
    //Cancel
    @IBAction func clickBtnCancel(_ sender: Any) {
        clickCancel?()
        dismiss(animated: true)
    }
    //요일 버튼
    @IBAction func clickWeekDay(_ sender:UIButton) {
        guard let button = sender as? WeekDayButton else {
            return
        }
        button.isSelected = !button.isSelected
    }
    //pickEndDate Change Value
    @IBAction func changeValueEndDate(_ sender:UIDatePicker) {
        // 날짜 선택 시 팝업 닫음
        presentedViewController?.dismiss(animated: false)
    }
}
