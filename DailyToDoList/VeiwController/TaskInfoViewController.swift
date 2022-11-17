//
//  TaskInfoViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/14.
//

import UIKit


class TaskInfoViewController : UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var popView:UIView!
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
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelOption: UILabel!
    @IBOutlet weak var labelMemo: UILabel!
    @IBOutlet weak var labelFirst:UILabel!
    @IBOutlet weak var labelSecond:UILabel!
    @IBOutlet weak var labelThird:UILabel!
    @IBOutlet weak var labelEndDate: UILabel!
    @IBOutlet weak var labelAlarm: UILabel!
    //
    @IBOutlet weak var btnPullCategory:UIButton!
    @IBOutlet weak var btnRepeat: UIButton!
    @IBOutlet weak var btnAlarm: UIButton!
    @IBOutlet weak var btnFirst:UIButton!
    @IBOutlet weak var btnSecond:UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnWrite: UIButton!
    //
    @IBOutlet weak var switchTime: UISwitch!
    @IBOutlet weak var switchEndDate: UISwitch!
    
    
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
    private var alarmtViewConstraint:NSLayoutConstraint?
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
        //
        scrollView.isScrollEnabled = false
        //날짜 지정
        pickTaskDate.setDate(currntDate, animated: false)
        //기본세팅
        observeKeyboard()
        setMode()
        //
        btnRepeat.titleLabel?.font = UIFont(name: K_Font_B, size: K_FontSize)
        btnAlarm.titleLabel?.font = UIFont(name: K_Font_B, size: K_FontSize)
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
        backgroundView.image = UIImage(named: BlackBackImage)
        view.insertSubview(backgroundView, at: 0)
        //
        pickTaskDate.overrideUserInterfaceStyle = .dark
        pickTaskTime.overrideUserInterfaceStyle = .dark
        pickEndDate.overrideUserInterfaceStyle = .dark
        pickAlarmTime.overrideUserInterfaceStyle = .dark
        //
        scrollView.backgroundColor = .clear
        popView.backgroundColor = .clear
        repeatView.backgroundColor = .clear
        alarmView.backgroundColor = .clear
        memoView.backgroundColor = .clear
        //
        labelTitle.font = UIFont(name: K_Font_B, size: K_FontSize)
        labelCategory.font = UIFont(name: K_Font_B, size: K_FontSize)
        labelSchedule.font = UIFont(name: K_Font_B, size: K_FontSize)
        labelOption.font = UIFont(name: K_Font_B, size: K_FontSize)
        labelMemo.font = UIFont(name: K_Font_B, size: K_FontSize)
        labelDate.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelTime.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelFirst.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelSecond.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelThird.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelEndDate.font = UIFont(name: K_Font_R, size: K_FontSize)
        labelAlarm.font = UIFont(name: K_Font_R, size: K_FontSize)
        //
        inputTitle.font = UIFont(name: K_Font_R, size: K_FontSize)
        memoView.font = UIFont(name: K_Font_R, size: K_FontSize)
        //
        btnPullCategory.layer.shadowColor = UIColor.darkGray.cgColor
        btnPullCategory.layer.shadowOpacity = 0.5
        btnPullCategory.layer.shadowOffset = CGSize.zero
        btnPullCategory.layer.shadowRadius = 6
        btnRepeat.layer.shadowColor = UIColor.darkGray.cgColor
        btnRepeat.layer.shadowOpacity = 0.5
        btnRepeat.layer.shadowOffset = CGSize.zero
        btnRepeat.layer.shadowRadius = 6
        btnAlarm.layer.shadowColor = UIColor.darkGray.cgColor
        btnAlarm.layer.shadowOpacity = 0.5
        btnAlarm.layer.shadowOffset = CGSize.zero
        btnAlarm.layer.shadowRadius = 6
        //
        btnWrite.setImage(UIImage(systemName: "pencil", withConfiguration: mediumConfig), for: .normal)
        btnWrite.tintColor = .systemBackground
        btnBack.setImage(UIImage(systemName: "chevron.backward", withConfiguration: mediumConfig), for: .normal)
        btnBack.tintColor = .systemBackground
    }
    //
    private func initGesture() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
        tapGesture.delegate = self
        
        self.view.addGestureRecognizer(tapGesture)
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
        inputTitle.attributedPlaceholder = NSAttributedString(string: "TODO를 입력해주세요", attributes: [NSAttributedString.Key.foregroundColor : UIColor.opaqueSeparator])
        //시간 끄기
        let isTime = false
        switchTime.isOn = isTime
        pickTaskTime.isEnabled = isTime
        switchEndDate.isOn = isTime
        pickEndDate.isEnabled = isTime
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
        pickTaskDate.date = Utils.dateStringToDate(taskData.taskDay)!
        if taskData.taskTime.isEmpty {
            switchTime.isOn = false
        } else {
            switchTime.isOn = false
            let date = taskData.taskDay + taskData.taskTime + ":00"
            pickTaskTime.date = Utils.stringToDate(date)!
        }
        //
        let repeatType = RepeatType(rawValue: taskData.repeatType)!
        let option = taskData.optionData ?? OptionData()
        let isEnd = option.isEnd
        let taskEndDate = option.taskEndDate
        if repeatType == .None {
            if btnRepeat.isSelected {
                btnRepeat.sendActions(for: .touchUpInside)
            }
        } else {
            if !btnRepeat.isSelected {
                btnRepeat.sendActions(for: .touchUpInside)
            }
            repeatResult = RepeatResult(repeatType: repeatType, weekDay: option.getWeekDayList(), weekOfMonth: option.weekOfMonth, isEnd: isEnd, endDate: Utils.dateStringToDate(taskEndDate))
        }
        showRepeatView(repeatType)
        if option.isAlarm {
            setAlarm()
        }
        memoView.text = taskData.memo
    }
    //카테고리 로드
    private func loadCategory() {
        //
        let funcLoadCategory:()->Void = self.loadCategory
        var actionList:[UIAction] = []
        let categories = RealmManager.shared.loadCategory()
        for category in categories {
            let image =  category.loadImage()
            let action = UIAction(title: category.title, image: image, handler: { [self] _ in
                btnPullCategory.setTitle(category.title, for: .normal)
                btnPullCategory.titleLabel?.font = UIFont(name: K_Font_B, size: K_FontSize)
                btnPullCategory.tintColor = category.loadColor()
                btnPullCategory.layer.cornerRadius = 10
            })
            let element = (category.title, action)
            categoryList.append(element)
            actionList.append(action)
        }
        //카테고리 추가 버튼
        let addCategory = UIAction(title: "카테고리 추가", attributes: .destructive, handler: { _ in
            let board = UIStoryboard(name: categoryBoard, bundle: nil)
            guard let colorVC = board.instantiateViewController(withIdentifier: categoryBoard) as? CategoryViewController else { return }
            
            colorVC.modalTransitionStyle = .coverVertical
            colorVC.modalPresentationStyle = .pageSheet
            colorVC.reloadCategory = funcLoadCategory
            
            self.present(colorVC, animated: true)
        })
        actionList.append(addCategory)
        btnPullCategory.menu = UIMenu(title: "카테고리", children: actionList)
        //첫 카테고리 선택
        btnPullCategory.sendAction(categoryList.first!.action)
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
        alarmtViewConstraint = alarmView.constraints.first { item in
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
        btnRepeat.isEnabled = isOn
        btnAlarm.isEnabled = isOn
        memoView.isEditable = isOn
    }
    //resultView 컨트롤
    private func controllRepeatView(_ isOpen:Bool) {
        if !isOpen {
            setRepeatResult()
        }
        repeatView.isHidden = !isOpen
        pickEndDate.isHidden = !isOpen
        labelEndDate.isHidden = !isOpen
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
        labelAlarm.isHidden = !isOpen
        pickAlarmTime.isHidden = !isOpen
        if isOpen {
            let anim = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) { [self] in
                alarmtViewConstraint?.constant = alarmViewSize!.height
            }
            anim.startAnimation()
        } else {
            let anim = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) { [self] in
                alarmtViewConstraint?.constant = 0
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
        labelFirst.isHidden = true
        labelSecond.isHidden = true
        labelThird.isHidden = true
        btnFirst.isHidden = true
        btnSecond.isHidden = true
    }
    private func setRepeatResult(_ thrid:String) {
        labelFirst.isHidden = true
        labelSecond.isHidden = true
        labelThird.isHidden = false
        labelThird.text = thrid
        //
        btnFirst.isHidden = true
        btnSecond.isHidden = true
    }
    private func setRepeatResult(_ second:String, _ btnsecond:String, _ thrid:String) {
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
    private func setRepeatResult(_ first:String, _ btnfirst:String, _ second:String, _ btnsecond:String, _ thrid:String) {
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
    //알람 세팅
    private func setAlarm() {
        guard let taskData = taskData else {
            return
        }
        let option = taskData.optionData ?? OptionData()
        pickAlarmTime.isHidden = !option.isAlarm
        let time = taskData.taskDay + option.alarmTime + ":00"
        pickAlarmTime.date = Utils.stringToDate(time)!
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
        if !pickEndDate.isEnabled && taskDay == Utils.dateToDateString(pickEndDate.date) {
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
        switch currentMode {
        case .ADD:
            data = EachTask(taskDay: pickTaskDate.date, category: category, time: "", title: title, memo: memoView.text!, repeatType: repeatType.rawValue)
            let option = OptionData(taskId: data.taskId, weekDay: weekDay, weekOfMonth: weekOfMonth)
            data.setOptionData(option)
        case .MODIFY:
            guard let taskData = taskData else {
                return nil
            }
            let option = OptionData(taskId: taskData.taskId, weekDay: weekDay, weekOfMonth: weekOfMonth)
            data = EachTask(id:taskData.taskId, taskDay: pickTaskDate.date, category: category, time: "", title: title, memo: memoView.text!, repeatType: repeatType.rawValue, optionData: option)
        default:
            break
        }
        if switchEndDate.isOn {
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
            RealmManager.shared.addTaskDataForiOS(data)
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
        if btnRepeat.isSelected {
            let board = UIStoryboard(name: repeatBoard, bundle: nil)
            guard let repeatVC = board.instantiateViewController(withIdentifier: repeatBoard) as? RepeatViewController else {
                return
            }
            //
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
    private func offRepeat() {
        setRepeatResult()
        repeatResult = nil
        controllRepeatView(false)
    }
    //AlarmView 열기
    @IBAction func clickAlarm(_ sender: Any) {
        btnAlarm.isSelected = !btnAlarm.isSelected
        //알람 활성화, 비활성화
        controllAlarmView(btnAlarm.isSelected)
    }
}

//MARK: - 스위치 이벤트
extension TaskInfoViewController {
    //
    @IBAction func clickSwitchTime(_ sender: UISwitch) {
        pickTaskTime.isEnabled = sender.isOn
    }
    //
    @IBAction func clickSwitchEndDate(_ sender: UISwitch) {
        pickEndDate.isEnabled = sender.isOn
    }
}
