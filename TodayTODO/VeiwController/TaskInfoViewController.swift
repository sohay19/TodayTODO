//
//  TaskInfoViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/14.
//

import UIKit


class TaskInfoViewController : UIViewController {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var popView:UIView!
    @IBOutlet weak var scheduleStackView: UIStackView!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var optionStackView: UIStackView!
    @IBOutlet weak var repeatView:UIView!
    @IBOutlet weak var alarmView: UIView!
    @IBOutlet weak var memoView:UITextView!
    //
    @IBOutlet weak var inputTitle:UITextField!
    //
    @IBOutlet weak var pickTaskDate:UIDatePicker!
    @IBOutlet weak var pickTaskTime: UIDatePicker!
    @IBOutlet weak var pickEndDate:UIDatePicker!
    @IBOutlet weak var pickAlarmTime:UIDatePicker!
    //
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var labelSchedule: UILabel!
    @IBOutlet weak var labelOption: UILabel!
    @IBOutlet weak var labelMemo: UILabel!
    @IBOutlet weak var labelRepeatType:UILabel!
    @IBOutlet weak var labelWeek:UILabel!
    @IBOutlet weak var labelWeekUnit:UILabel!
    @IBOutlet weak var labelDay:UILabel!
    @IBOutlet weak var labelDayUnit:UILabel!
    @IBOutlet weak var textCounter: UILabel!
    @IBOutlet weak var memoCounter: UILabel!
    //
    @IBOutlet weak var btnPullCategory:UIButton!
    @IBOutlet weak var btnAllDay: UIButton!
    @IBOutlet weak var btnRepeat: UIButton!
    @IBOutlet weak var btnAlarm: UIButton!
    @IBOutlet weak var btnEndDate: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnModify: UIButton!
    @IBOutlet weak var btnWrite: UIButton!
    //
    @IBOutlet weak var menuIcon: UIImageView!
    
    
    //
    var taskData:EachTask?
    var repeatResult:RepeatResult?
    var currentMode:TaskMode = .LOOK
    //
    var currntDate:Date = Date()
    //
    var refreshTask:(()->Void)?
    var modifyTask:((EachTask)->Void)?
    //
    //키보드 관련
    var keyboardHeight:CGFloat?
    var bottomConstraint:NSLayoutConstraint?
    //
    var isShow = false
    var isRefresh = false
    //
    private var categoryList:[(name:String, action:UIAction)] = []
    //
    let backgroundView = UIImageView(frame: UIScreen.main.bounds)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        inputTitle.delegate = self
        memoView.delegate = self
        //
        view.insertSubview(backgroundView, at: 0)
        initGesture()
        //
        bottomConstraint = self.view.constraints.first {$0.identifier == "bottomHeight"}
    }
    //
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        scrollView.isScrollEnabled = false
        //
        initUI()
        pickTaskDate.setDate(currntDate, animated: false)
        loadCategory()
        observeKeyboard()
        //
        setMode()
    }
}

//MARK: - initialize
extension TaskInfoViewController {
    //
    private func initUI() {
        // 배경 설정
        backgroundView.image = UIImage(named: BackgroundImage)
        backView.backgroundColor = .clear
        //
        let K_B_FontSize = K_FontSize + 3.0
        let bold = UIFont(name: K_Font_B, size: K_B_FontSize)
        let regular = UIFont(name: K_Font_R, size: K_FontSize)
        scrollView.backgroundColor = .clear
        popView.backgroundColor = .clear
        scheduleStackView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        scheduleStackView.layer.cornerRadius = 5
        scheduleStackView.layer.borderWidth = 0.1
        scheduleStackView.layer.borderColor = UIColor.gray.cgColor
        optionStackView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        optionStackView.layer.cornerRadius = 5
        optionStackView.layer.borderWidth = 0.1
        optionStackView.layer.borderColor = UIColor.gray.cgColor
        repeatView.backgroundColor = .clear
        alarmView.backgroundColor = .clear
        memoView.backgroundColor = .clear
        memoView.contentInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        //
        labelTitle.font = bold
        labelCategory.font = bold
        labelSchedule.font = bold
        labelOption.font = bold
        labelMemo.font = bold
        labelRepeatType.font = regular
        labelWeek.font = regular
        labelWeekUnit.font = regular
        labelDay.font = regular
        labelDayUnit.font = regular
        //
        labelTitle.textColor = .label
        labelCategory.textColor = .label
        labelSchedule.textColor = .label
        labelOption.textColor = .label
        labelMemo.textColor = .label
        labelRepeatType.textColor = .label
        labelWeekUnit.textColor = .label
        labelDayUnit.textColor = .label
        //
        inputTitle.font = regular
        inputTitle.textColor = .label
        inputTitle.backgroundColor = .lightGray.withAlphaComponent(0.1)
        inputTitle.clearButtonMode = .whileEditing
        textCounter.textColor = .label
        textCounter.font = UIFont(name: N_Font, size: N_FontSize - 5.0)
        memoCounter.textColor = .label
        memoCounter.font = UIFont(name: N_Font, size: N_FontSize - 5.0)
        //
        btnPullCategory.titleLabel?.font = UIFont(name: K_Font_B, size: K_FontSize)
        btnPullCategory.layer.cornerRadius = 5
        btnRepeat.titleLabel?.font = UIFont(name: K_Font_B, size: K_FontSize)
        btnRepeat.backgroundColor = .clear
        btnRepeat.tintColor = .darkGray
        btnAlarm.titleLabel?.font = UIFont(name: K_Font_B, size: K_FontSize)
        btnAlarm.backgroundColor = .clear
        btnAlarm.tintColor = .darkGray
        btnAllDay.titleLabel?.font = regular
        btnAllDay.tintColor = .gray
        btnEndDate.titleLabel?.font = regular
        btnEndDate.tintColor = .darkGray
        //
        btnWrite.setTitle("확인", for: .normal)
        btnWrite.titleLabel?.font = bold
        btnWrite.backgroundColor = .label
        btnWrite.tintColor = .systemBackground
        btnModify.setImage(UIImage(systemName: "eraser", withConfiguration: mediumConfig), for: .normal)
        btnModify.tintColor = .label
        btnBack.setImage(UIImage(systemName: "chevron.backward", withConfiguration: mediumConfig), for: .normal)
        btnBack.tintColor = .label
    }
    // 키보드 위의 Done 버튼 세팅
    private func initInput() {
        let keyboardToolbar = UIToolbar()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(
            title: "Done",
            style: .plain,
            target: self,
            action: #selector(keyboardDown))
        let font = UIFont(name: E_Font_B, size: E_FontSize)
        doneBarButton.setTitleTextAttributes([.font:font!], for: .normal)
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        keyboardToolbar.sizeToFit()
        keyboardToolbar.tintColor = UIColor.label
        
        memoView.inputAccessoryView = keyboardToolbar
    }
    //
    private func initGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(keyboardDown))
        tapGesture.numberOfTapsRequired = 1
        backView.addGestureRecognizer(tapGesture)
    }
    //
    private func setMode() {
        //
        setDefaultUI()
        switch currentMode {
        case .ADD:
            btnWrite.isHidden = false
            btnModify.isHidden = true
            textCounter.isHidden = false
            memoCounter.isHidden = false
            controllEditMode(true)
        case .LOOK:
            btnWrite.isHidden = true
            btnModify.isHidden = false
            textCounter.isHidden = true
            memoCounter.isHidden = true
            controllEditMode(false)
            loadData()
        case .MODIFY:
            btnWrite.isHidden = false
            btnModify.isHidden = true
            textCounter.isHidden = false
            memoCounter.isHidden = false
            controllEditMode(true)
            loadData()
        }
        SystemManager.shared.closeLoading()
        if isRefresh {
            endAppearanceTransition()
            isRefresh = false
        }
    }
    //
    private func setDefaultUI() {
        inputTitle.attributedPlaceholder = NSAttributedString(string: "TODO를 입력해주세요", attributes: [NSAttributedString.Key.foregroundColor : UIColor.secondaryLabel])
        //시간, 종료일 끄기
        controllTimeView(true)
        controllEndDate(false)
        //반복, 알람 닫기
        controllRepeatView(false)
        controllAlarmView(false)
        setRepeatResult()
        //항상 꺼둠
        btnEndDate.isEnabled = false
        pickEndDate.isEnabled = false
        //
        guard let date = Calendar.current.date(byAdding: .minute, value: 5, to: currntDate) else {
            return
        }
        pickTaskTime.setDate(date, animated: true)
        pickAlarmTime.setDate(date, animated: true)
    }
    //
    private func loadData() {
        guard let taskData = taskData else {
            return
        }
        //title, category
        inputTitle.text = taskData.title
        textCounter.text = "\(taskData.title.count)/20"
        for item in categoryList {
            if item.name == taskData.category {
                btnPullCategory.sendAction(item.action)
                break
            }
        }
        //날짜
        pickTaskDate.date = Utils.dateStringToDate(taskData.taskDay)!
        //시간
        controllTimeView(taskData.taskTime.isEmpty ? true : false)
        if !btnAllDay.isSelected {
            let time = Utils.transTime(taskData.taskDay, taskData.taskTime)
            pickTaskTime.date = time
        }
        //반복(+종료일)
        let repeatType = RepeatType(rawValue: taskData.repeatType)!
        let option = taskData.optionData ?? OptionData()
        let isEnd = option.isEnd
        let taskEndDate = option.taskEndDate
        if repeatType != .None {
            clickBtnRepeat(true)
            repeatResult = RepeatResult(repeatType: repeatType, weekDay: option.getWeekDayList(), weekOfMonth: option.weekOfMonth, isEnd: isEnd, endDate: Utils.dateStringToDate(taskEndDate))
        }
        showRepeatView(repeatType)
        //알람
        if option.isAlarm {
            clickBtnAlarm(true)
            setAlarm()
        }
        //
        if let font = UIFont(name: K_Font_R, size: K_FontSize) {
            memoView.setLineSpacing(taskData.memo, font: font, color: .label, align: .left)
            memoCounter.text = "\(taskData.memo.count)/300"
        }
    }
    //카테고리 로드
    private func loadCategory() {
        var actionList:[UIAction] = []
        let categories = DataManager.shared.getAllCategory()
        for category in categories {
            let image =  category.loadImage()
            let action = UIAction(title: category.title, image: image, handler: { [self] _ in
                btnPullCategory.setTitle(category.title, for: .normal)
                btnPullCategory.backgroundColor = category.loadColor()
            })
            let element = (category.title, action)
            categoryList.append(element)
            actionList.append(action)
        }
        //카테고리 추가 버튼
        let addCategory = UIAction(title: "카테고리 추가", attributes: .destructive, handler: { [self] _ in
            btnPullCategory.sendAction(actionList[0])
            let board = UIStoryboard(name: addCategoryBoard, bundle: nil)
            guard let addCategoryVC = board.instantiateViewController(withIdentifier: addCategoryBoard) as? AddCategoryViewController else { return }
            addCategoryVC.reloadCategory = self.loadCategory
            addCategoryVC.modalTransitionStyle = .coverVertical
            addCategoryVC.modalPresentationStyle = .overFullScreen
            guard let navigation = self.navigationController as? CustomNavigationController else {
                return
            }
            navigation.present(addCategoryVC, animated: true)
        })
        actionList.append(addCategory)
        btnPullCategory.menu = UIMenu(title: "카테고리", children: actionList)
        //첫 카테고리 선택
        btnPullCategory.sendAction(actionList[0])
    }
}

//MARK: - controll
extension TaskInfoViewController {
    //수정가능 상태로 변경
    private func controllEditMode(_ isOn:Bool) {
        inputTitle.isEnabled = isOn
        btnPullCategory.isEnabled = isOn
        menuIcon.isHidden = !isOn
        pickTaskDate.isEnabled = isOn
        btnAllDay.isEnabled = isOn
        pickTaskTime.isEnabled = isOn
        btnRepeat.isEnabled = isOn
        btnAlarm.isEnabled = isOn
        pickAlarmTime.isEnabled = isOn
        memoView.isEditable = isOn
    }
    //resultView 컨트롤
    private func controllRepeatView(_ isOpen:Bool) {
        repeatView.isHidden = !isOpen
    }
    //AlarmtView 컨트롤
    private func controllAlarmView(_ isOpen:Bool) {
        alarmView.isHidden = !isOpen
    }
    //resultView 결과
    private func loadResult(_ result:RepeatResult) {
        repeatResult = result
        //종료일
        guard let repeatResult = repeatResult else {
            return
        }
        showRepeatView(repeatResult.repeatType)
    }
    //
    private func showRepeatView(_ repeatType:RepeatType) {
        var weekDay:String
        var day:String
        var weekOfMonth:String
        var isEnd = false
        var date = ""
        //
        if let repeatResult = repeatResult {
            weekDay = repeatResult.getWeekDay()
            day = String(Utils.dateToDateString(pickTaskDate.date).split(separator: "-")[2])
            weekOfMonth = Utils.getWeekOfMonthInKOR(repeatResult.weekOfMonth)
            isEnd = repeatResult.isEnd
            if let endDate = repeatResult.taskEndDate {
                date = Utils.dateToDateString(endDate)
            }
        } else {
            guard let taskData = taskData else {
                return
            }
            let option = taskData.optionData ?? OptionData()
            weekDay = taskData.printWeekDay()
            day = String(taskData.taskDay.split(separator: "-")[2])
            weekOfMonth = Utils.getWeekOfMonthInKOR(option.weekOfMonth)
            isEnd = option.isEnd
            date = option.taskEndDate
        }
        controllEndDate(isEnd)
        if isEnd {
            pickEndDate.date = Utils.dateStringToDate(date)!
        }
        //
        switch repeatType  {
        case .None:
            setRepeatResult()
            controllRepeatView(false)
        case .EveryDay:
            setRepeatResult("매일")
            controllRepeatView(true)
        case .Eachweek:
            setRepeatResult("매 주", weekDay, "요일")
            controllRepeatView(true)
        case .EachOnceOfMonth:
            setRepeatResult("매 월", day, "일")
            controllRepeatView(true)
        case .EachWeekOfMonth:
            setRepeatResult("매 월", weekOfMonth, "주,", weekDay, "요일")
            controllRepeatView(true)
        case .EachYear:
            setRepeatResult("매 년", day, "일")
            controllRepeatView(true)
        }
    }
    //repeatResult setting
    private func setRepeatResult() {
        labelRepeatType.isHidden = true
        labelWeekUnit.isHidden = true
        labelDayUnit.isHidden = true
        labelWeek.isHidden = true
        labelDay.isHidden = true
    }
    private func setRepeatResult(_ dayUnit:String) {
        labelRepeatType.isHidden = true
        labelWeekUnit.isHidden = true
        labelDayUnit.isHidden = false
        labelDayUnit.text = dayUnit
        //
        labelWeek.isHidden = true
        labelDay.isHidden = true
    }
    private func setRepeatResult(_ weekUnit:String, _ day:String, _ dayUnit:String) {
        labelRepeatType.isHidden = true
        labelWeekUnit.isHidden = false
        labelWeekUnit.text = weekUnit
        labelDayUnit.isHidden = false
        labelDayUnit.text = dayUnit
        //
        labelWeek.isHidden = true
        labelDay.isHidden = false
        labelDay.text = day
    }
    private func setRepeatResult(_ type:String, _ week:String, _ weekUnit:String, _ day:String, _ dayUnit:String) {
        labelRepeatType.isHidden = false
        labelRepeatType.text = type
        labelWeekUnit.isHidden = false
        labelWeekUnit.text = weekUnit
        labelDayUnit.isHidden = false
        labelDayUnit.text = dayUnit
        //
        labelWeek.isHidden = false
        labelWeek.text = week
        labelDay.isHidden = false
        labelDay.text = day
    }
    //알람 세팅
    private func setAlarm() {
        guard let taskData = taskData else {
            return
        }
        let option = taskData.optionData ?? OptionData()
        pickAlarmTime.isHidden = !option.isAlarm
        let time = Utils.transTime(taskData.taskDay, option.alarmTime)
        pickAlarmTime.date = time
    }
}

//MARK: - Button Event
extension TaskInfoViewController {
    private func checkInfo(_ complete: @escaping (EachTask)->Void) {
        SystemManager.shared.openLoading()
        //제목검토
        guard let title = inputTitle.text else {
            SystemManager.shared.closeLoading()
            return
        }
        if title.isEmpty {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "타이틀을 입력해주세요")
            SystemManager.shared.closeLoading()
            return
        }
        //카테고리 검토
        guard let _ = btnPullCategory.currentTitle else {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "카테고리를 선택해주세요")
            SystemManager.shared.closeLoading()
            return
        }
        //알람 검토
        if btnAlarm.isSelected && btnRepeat.isSelected {
            if !btnEndDate.isSelected {
                PopupManager.shared.openOkAlert(self, title: "알림", msg: "알람은 최대 60개까지 등록 가능합니다")
                SystemManager.shared.closeLoading()
                return
            }
            guard let repeatResult = repeatResult else {
                SystemManager.shared.closeLoading()
                return
            }
            //
            var repeatCounter = 0
            let time = Utils.dateToTimeString(pickAlarmTime.date).components(separatedBy: ":").map{Int($0)!}
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            dateComponents.hour = time[0]
            dateComponents.minute = time[1]
            switch repeatResult.repeatType {
            case .EveryDay:
                repeatCounter = Utils.calcConter(dateComponents: dateComponents, startDate: pickTaskDate.date, endDate: pickEndDate.date)
            case .Eachweek:
                for (i, week) in repeatResult.weekDay.enumerated() {
                    if week {
                        dateComponents.weekday = i+1
                        repeatCounter += Utils.calcConter(dateComponents: dateComponents, startDate: pickTaskDate.date, endDate: pickEndDate.date)
                    }
                }
            case .EachOnceOfMonth:
                dateComponents.day = Utils.getDay(pickTaskDate.date)
                repeatCounter = Utils.calcConter(dateComponents: dateComponents, startDate: pickTaskDate.date, endDate: pickEndDate.date)
            case .EachWeekOfMonth:
                let weekOfMonth = repeatResult.weekOfMonth
                if weekOfMonth == -1 {
                    dateComponents.weekdayOrdinal = weekOfMonth
                } else {
                    dateComponents.weekOfMonth = weekOfMonth
                }
                for (i, week) in repeatResult.weekDay.enumerated() {
                    if week {
                        dateComponents.weekday = i+1
                        repeatCounter += Utils.calcConter(dateComponents: dateComponents, startDate: pickTaskDate.date, endDate: pickEndDate.date)
                    }
                }
            case .EachYear:
                dateComponents.month = Utils.getMonth(pickTaskDate.date)
                dateComponents.day = Utils.getDay(pickTaskDate.date)
                repeatCounter = Utils.calcConter(dateComponents: dateComponents, startDate: pickTaskDate.date, endDate: pickEndDate.date)
            default:
                SystemManager.shared.closeLoading()
                break
            }
            DataManager.shared.getAllPush { [self] list in
                DispatchQueue.main.sync {
                    let remainPush = 60 - list.count
                    let resultPush = remainPush - repeatCounter
                    if resultPush < 0 {
                        PopupManager.shared.openOkAlert(self, title: "알림", msg: "남은 알람 개수가 충분하지 않습니다\n(남은 알람 수 = \(remainPush))")
                        SystemManager.shared.closeLoading()
                    } else {
                        saveTask(complete)
                    }
                }
            }
        } else {
            saveTask(complete)
        }
    }
    private func saveTask(_ complete: @escaping (EachTask)->Void) {
        guard let title = inputTitle.text else {
            SystemManager.shared.closeLoading()
            return
        }
        guard let category = btnPullCategory.currentTitle else {
            SystemManager.shared.closeLoading()
            return
        }
        //반복 내용 가져오기
        var repeatType = RepeatType.None
        var weekDay = [Bool](repeating: false, count: 7)
        var weekOfMonth = 0
        if btnRepeat.isSelected {
            //RepeatResult 내용 가져오기
            guard let repeatResult = repeatResult else {
                SystemManager.shared.closeLoading()
                return
            }
            repeatType = repeatResult.repeatType
            weekDay = repeatResult.weekDay
            weekOfMonth = repeatResult.weekOfMonth
        }
        //태스크 생성
        var data = EachTask()
        let time = btnAllDay.isSelected ? "" : Utils.dateToTimeString(pickTaskTime.date)
        switch currentMode {
        case .ADD:
            data = EachTask(taskDay: pickTaskDate.date, category: category, time: time, title: title, memo: memoView.text!, repeatType: repeatType.rawValue)
            let option = OptionData(taskId: data.taskId, weekDay: weekDay, weekOfMonth: weekOfMonth)
            data.setOptionData(option)
        case .MODIFY:
            guard let taskData = taskData else {
                SystemManager.shared.closeLoading()
                return
            }
            let option = OptionData(taskId: taskData.taskId, weekDay: weekDay, weekOfMonth: weekOfMonth)
            data = EachTask(id:taskData.taskId, taskDay: pickTaskDate.date, category: category, time: time, title: title, memo: memoView.text!, repeatType: repeatType.rawValue, optionData: option)
        default:
            SystemManager.shared.closeLoading()
            break
        }
        //종료일 확인
        if btnEndDate.isSelected {
            data.setEndDate(pickEndDate.date)
        }
        //알람 확인
        if btnAlarm.isSelected {
            data.setAlarm(pickAlarmTime.date)
        }
        //
        complete(data)
    }
    //등록버튼
    @IBAction func clickSubmit(_ sender: Any) {
        switch currentMode {
        case .ADD:
            checkInfo { [self] data in
                //realm에 추가
                DataManager.shared.addTask(data)
                SystemManager.shared.closeLoading()
                guard let refreshTask = refreshTask, let navigationController = self.navigationController as? CustomNavigationController else {
                    return
                }
                navigationController.popViewController {
                    refreshTask()
                }
            }
        case .MODIFY:
            checkInfo() { [self] data in
                guard let modifyTask = modifyTask else {
                    return
                }
                modifyTask(data)
                SystemManager.shared.closeLoading()
                guard let refreshTask = refreshTask, let navigationController = self.navigationController as? CustomNavigationController else {
                    return
                }
                navigationController.popViewController {
                    refreshTask()
                }
            }
        default:
            //Look
            break
        }
    }
    //수정버튼
    @IBAction func clickModify(_ sender: Any) {
        repeatResult = nil
        currentMode = .MODIFY
        refresh()
    }
    private func refresh() {
        isRefresh = true
        beginAppearanceTransition(true, animated: false)
    }
    // 날짜 선택 시 팝업 닫음
    @IBAction func changeDate(_ sender:UIDatePicker) {
        // 반복 지정 초기화
        offRepeat()
        presentedViewController?.dismiss(animated: false)
        clickBtnRepeat(false)
    }
    //시간 선택 시 알람 시간 변경
    @IBAction func changeTime(_ sender:UIDatePicker) {
        pickAlarmTime.date = sender.date
    }
    @IBAction func clickBack(_ sender:Any) {
        guard let navigation = self.navigationController as? CustomNavigationController else {
            return
        }
        navigation.popViewController()
    }
    //RepeatView 열기
    @IBAction func clickRepeat(_ sender: Any) {
        btnRepeat.isSelected = !btnRepeat.isSelected
        clickBtnRepeat(btnRepeat.isSelected)
        if btnRepeat.isSelected {
            let board = UIStoryboard(name: repeatBoard, bundle: nil)
            guard let repeatVC = board.instantiateViewController(withIdentifier: repeatBoard) as? RepeatViewController else {
                return
            }
            repeatVC.pickDate = pickTaskDate.date
            repeatVC.clickOk = loadResult(_:)
            repeatVC.clickCancel = { self.clickBtnRepeat(false) }
            repeatVC.modalPresentationStyle = .overCurrentContext
            repeatVC.modalTransitionStyle = .crossDissolve
            guard let navigationController = self.navigationController else {
                return
            }
            navigationController.present(repeatVC, animated: true)
        } else {
            offRepeat()
        }
    }
    private func clickBtnRepeat(_ isOn:Bool) {
        btnRepeat.setImage(UIImage(systemName: isOn ? "checkmark.square.fill" : "square.fill"), for: .normal)
        btnRepeat.isSelected = isOn
    }
    private func offRepeat() {
        setRepeatResult()
        repeatResult = nil
        controllRepeatView(false)
    }
    //AlarmView 열기
    @IBAction func clickAlarm(_ sender: Any) {
        btnAlarm.isSelected = !btnAlarm.isSelected
        clickBtnAlarm(btnAlarm.isSelected)
    }
    private func clickBtnAlarm(_ isOn:Bool) {
        btnAlarm.setImage(UIImage(systemName: isOn ? "checkmark.square.fill" : "square.fill"), for: .normal)
        btnAlarm.isSelected = isOn
        controllAlarmView(isOn)
    }
    //종일
    @IBAction func clickAllDay(_ sender: Any) {
        btnAllDay.isSelected = !btnAllDay.isSelected
        controllTimeView(btnAllDay.isSelected)
    }
    private func controllTimeView(_ isOn:Bool) {
        btnAllDay.setImage(UIImage(systemName: isOn ? "checkmark.square.fill" : "square.fill"), for: .normal)
        btnAllDay.isSelected = isOn
        timeView.isHidden = isOn
    }
    //
    @IBAction func clickEndDate(_ sender: Any) {
        btnEndDate.isSelected = !btnEndDate.isSelected
        controllEndDate(btnEndDate.isSelected)
    }
    private func controllEndDate(_ isOn:Bool) {
        btnEndDate.setImage(UIImage(systemName: isOn ? "checkmark.square.fill" : "square.fill"), for: .normal)
        btnEndDate.isSelected = isOn
    }
}
