//
//  TaskInfoViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/14.
//

import UIKit


class TaskInfoViewController : UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var popView:UIView!
    @IBOutlet weak var scheduleStackView: UIStackView!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var repeatStackView: UIStackView!
    @IBOutlet weak var repeatView:UIView!
    @IBOutlet weak var alarmStackView: UIStackView!
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
    //
    @IBOutlet weak var btnPullCategory:UIButton!
    @IBOutlet weak var btnAllDay: UIButton!
    @IBOutlet weak var btnRepeat: UIButton!
    @IBOutlet weak var btnAlarm: UIButton!
    @IBOutlet weak var btnEndDate: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnWrite: UIButton!
    
    
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
    var isShow = false
    //View 관련
    private var repeatViewSize:CGSize?
    private var repeatViewConstraint:NSLayoutConstraint?
    private var alarmViewSize:CGSize?
    private var alarmViewConstraint:NSLayoutConstraint?
    private var timeViewSize:CGSize?
    private var timeViewConstraint:NSLayoutConstraint?
    //
    private var categoryList:[(name:String, action:UIAction)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        initUI()
        initGesture()
        saveDefaultSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        scrollView.isScrollEnabled = false
        //날짜 지정
        pickTaskDate.setDate(currntDate, animated: false)
        //기본세팅
        observeKeyboard()
        setMode()
        //
        loadCategory()
    }
}

//MARK: - initialize
extension TaskInfoViewController {
    //
    private func initUI() {
        // 배경 설정
        let backgroundView = UIImageView(frame: UIScreen.main.bounds)
        backgroundView.image = UIImage(named: BackgroundImage)
        view.insertSubview(backgroundView, at: 0)
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
        repeatStackView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        repeatStackView.layer.cornerRadius = 5
        repeatStackView.layer.borderWidth = 0.1
        repeatStackView.layer.borderColor = UIColor.gray.cgColor
        alarmStackView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        alarmStackView.layer.cornerRadius = 5
        alarmStackView.layer.borderWidth = 0.1
        alarmStackView.layer.borderColor = UIColor.gray.cgColor
        repeatView.backgroundColor = .clear
        alarmView.backgroundColor = .clear
        memoView.backgroundColor = .clear
        memoView.font = regular
        memoView.textColor = .label
        memoView.contentInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        //
        labelTitle.font = bold
        labelCategory.font = bold
        labelSchedule.font = bold
        labelOption.font = bold
        labelMemo.font = bold
        labelRepeatType.font = regular
        labelWeekUnit.font = regular
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
        //
        btnPullCategory.titleLabel?.font = UIFont(name: K_Font_B, size: K_FontSize)
        btnPullCategory.layer.shadowColor = UIColor.gray.cgColor
        btnPullCategory.layer.shadowOffset = CGSize.zero
        btnPullCategory.layer.shadowOpacity = 0.3
        btnPullCategory.layer.shadowRadius = 6
        btnPullCategory.layer.cornerRadius = 5
        btnRepeat.titleLabel?.font = UIFont(name: K_Font_B, size: K_FontSize)
        btnRepeat.backgroundColor = .clear
        btnAlarm.titleLabel?.font = UIFont(name: K_Font_B, size: K_FontSize)
        btnAlarm.backgroundColor = .clear
        btnAllDay.titleLabel?.font = regular
        btnAllDay.tintColor = .darkGray
        btnEndDate.titleLabel?.font = regular
        btnEndDate.tintColor = .darkGray
        //
        btnWrite.setImage(UIImage(systemName: "pencil", withConfiguration: mediumConfig), for: .normal)
        btnWrite.tintColor = .label
        btnBack.setImage(UIImage(systemName: "chevron.backward", withConfiguration: mediumConfig), for: .normal)
        btnBack.tintColor = .label
    }
    //
    private func initGesture() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(keyboardDown))
        tapGesture.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(tapGesture)
        let focusGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(focusedMemoView))
        focusGesture.numberOfTapsRequired = 1
        memoView.addGestureRecognizer(focusGesture)
    }
    //
    private func setMode() {
        //
        setDefaultUI()
        switch currentMode {
        case .ADD:
            controllEditMode(true)
        case .LOOK:
            controllEditMode(false)
            loadData()
        case .MODIFY:
            controllEditMode(true)
            loadData()
        }
        DispatchQueue.main.async {
            SystemManager.shared.closeLoading()
        }
    }
    //
    private func setDefaultUI() {
        inputTitle.attributedPlaceholder = NSAttributedString(string: "TODO를 입력해주세요", attributes: [NSAttributedString.Key.foregroundColor : UIColor.secondaryLabel])
        //시간, 종료일 끄기
        contorllTimeView(true)
        controllEndDate(false)
        //반복, 알람 닫기
        controllRepeatView(false)
        controllAlarmView(false)
        setRepeatResult()
    }
    //
    private func loadData() {
        guard let taskData = taskData else {
            return
        }
        //title, category
        inputTitle.text = taskData.title
        for item in categoryList {
            if item.name == taskData.category {
                btnPullCategory.sendAction(item.action)
                break
            }
        }
        //날짜
        pickTaskDate.date = Utils.dateStringToDate(taskData.taskDay)!
        //시간
        contorllTimeView(taskData.taskTime.isEmpty ? true : false)
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
            repeatResult = RepeatResult(repeatType: repeatType, weekDay: option.getWeekDayList(), weekOfMonth: option.weekOfMonth, isEnd: isEnd, endDate: Utils.dateStringToDate(taskEndDate))
        }
        showRepeatView(repeatType)
        //알람
        if option.isAlarm {
            setAlarm()
            clickBtnAlarm(true)
        }
        memoView.text = taskData.memo
    }
    //카테고리 로드
    private func loadCategory() {
        //
        var actionList:[UIAction] = []
        let categories = DataManager.shared.loadCategory()
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
            
            self.present(addCategoryVC, animated: true)
        })
        actionList.append(addCategory)
        btnPullCategory.menu = UIMenu(title: "카테고리", children: actionList)
        //첫 카테고리 선택
        btnPullCategory.sendAction(actionList[0])
    }
    //
    private func saveDefaultSize() {
        //기존 사이즈 저장
        repeatViewSize = repeatView.frame.size
        alarmViewSize = alarmView.frame.size
        //
        repeatView.translatesAutoresizingMaskIntoConstraints = false
        repeatViewConstraint = repeatView.constraints.first { item in
            return item.identifier == "repeatViewHeight"
        }
        alarmView.translatesAutoresizingMaskIntoConstraints = false
        alarmViewConstraint = alarmView.constraints.first { item in
            return item.identifier == "alarmViewHeight"
        }
    }
}

//MARK: - controll
extension TaskInfoViewController {
    //수정가능 상태로 변경
    private func controllEditMode(_ isOn:Bool) {
        inputTitle.isEnabled = isOn
        btnPullCategory.isEnabled = isOn
        pickTaskDate.isEnabled = isOn
        btnAllDay.isEnabled = isOn
        pickTaskTime.isEnabled = isOn
        btnRepeat.isEnabled = isOn
        btnEndDate.isEnabled = isOn
        pickEndDate.isEnabled = isOn
        btnAlarm.isEnabled = isOn
        pickAlarmTime.isEnabled = isOn
        memoView.isEditable = isOn
    }
    //resultView 컨트롤
    private func controllRepeatView(_ isOpen:Bool) {
        if !isOpen {
            setRepeatResult()
        }
        repeatView.isHidden = !isOpen
        pickEndDate.isHidden = !isOpen
        if isOpen {
            let anim = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) { [self] in
                repeatViewConstraint?.constant = repeatViewSize!.height
            }
            anim.startAnimation()
        } else {
            let anim = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) { [self] in
                repeatViewConstraint?.constant = 0
            }
            anim.startAnimation()
        }
    }
    //AlarmtView 컨트롤
    private func controllAlarmView(_ isOpen:Bool) {
        pickAlarmTime.isHidden = !isOpen
        if isOpen {
            let anim = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) { [self] in
                alarmViewConstraint?.constant = alarmViewSize!.height
            }
            anim.startAnimation()
        } else {
            let anim = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) { [self] in
                alarmViewConstraint?.constant = 0
            }
            anim.startAnimation()
        }
    }
    //TimeView 컨트롤
    private func controllTimeView(_ isOpen:Bool) {
        pickTaskTime.isHidden = isOpen
        if isOpen {
            let anim = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) { [self] in
                timeViewConstraint?.constant = 0
            }
            anim.startAnimation()
        } else {
            let anim = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) { [self] in
                timeViewConstraint?.constant = timeViewSize!.height
            }
            anim.startAnimation()
        }
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
            date = Utils.dateToDateString(repeatResult.taskEndDate!)
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
        pickEndDate.isHidden = !isEnd
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
            setRepeatResult("매 월", weekOfMonth, "주, ", weekDay, "요일")
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
    private func makeTask() -> EachTask? {
        //제목검토
        guard let title = inputTitle.text else {
            return nil
        }
        if title.isEmpty {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "타이틀을 입력해주세요")
            return nil
        }
        //카테고리 검토
        guard let category = btnPullCategory.currentTitle else {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "카테고리를 선택해주세요")
            return nil
        }
        //종료일 검토
        let taskDay = Utils.dateToDateString(pickTaskDate.date)
        if btnEndDate.isSelected && taskDay == Utils.dateToDateString(pickEndDate.date) {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "시작일과 종료일이 같을 수 없습니다.")
            return nil
        }
        //
        SystemManager.shared.openLoading()
        //반복 내용 가져오기
        var repeatType = RepeatType.None
        var weekDay = [Bool](repeating: false, count: 7)
        var weekOfMonth = 0
        if btnRepeat.isSelected {
            //RepeatResult 내용 가져오기
            guard let repeatResult = repeatResult else {
                return nil
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
                return nil
            }
            let option = OptionData(taskId: taskData.taskId, weekDay: weekDay, weekOfMonth: weekOfMonth)
            data = EachTask(id:taskData.taskId, taskDay: pickTaskDate.date, category: category, time: time, title: title, memo: memoView.text!, repeatType: repeatType.rawValue, optionData: option)
        default:
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
        return data
    }
    //등록버튼
    @IBAction func clickSubmit(_ sender: Any) {
        switch currentMode {
        case .ADD:
            guard let data = makeTask() else {
                print("task is Nil")
                SystemManager.shared.closeLoading()
                return
            }
            //realm에 추가
            DataManager.shared.addTask(data)
        case .MODIFY:
            guard let data = makeTask() else {
                print("task is Nil")
                SystemManager.shared.closeLoading()
                return
            }
            guard let modifyTask = modifyTask else {
                return
            }
            modifyTask(data)
        default:
            //Look
            break
        }
        guard let refreshTask = refreshTask, let navigationController = self.navigationController as? CustomNavigationController else {
            return
        }
        navigationController.popViewController {
            refreshTask()
        }
    }
    // 날짜 선택 시 팝업 닫음
    @IBAction func changeDate(_ sender:UIDatePicker) {
        presentedViewController?.dismiss(animated: false)
        // 반복 지정 초기화
        btnRepeat.sendActions(for: .touchUpInside)
        offRepeat()
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
            repeatVC.clickCancel = { self.btnRepeat.isSelected = false }
            repeatVC.modalPresentationStyle = .overCurrentContext
            repeatVC.modalTransitionStyle = .crossDissolve
            
            present(repeatVC, animated: true)
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
        contorllTimeView(btnAllDay.isSelected)
    }
    private func contorllTimeView(_ isOn:Bool) {
        btnAllDay.isSelected = isOn
        timeView.isHidden = isOn
    }
    //
    @IBAction func clickEndDate(_ sender: Any) {
        btnEndDate.isSelected = !btnEndDate.isSelected
        controllEndDate(btnEndDate.isSelected)
    }
    private func controllEndDate(_ isOn:Bool) {
        btnEndDate.isSelected = isOn
        pickEndDate.isEnabled = isOn
    }
}
