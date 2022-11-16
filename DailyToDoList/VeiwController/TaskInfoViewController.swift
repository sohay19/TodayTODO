//
//  TaskInfoViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/14.
//

import UIKit


class TaskInfoViewController : UIViewController {
    @IBOutlet weak var popView:UIView!
    @IBOutlet weak var resultView:UIView!
    @IBOutlet weak var textView:UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    //
    @IBOutlet weak var inputTitle:UITextField!
    //
    @IBOutlet weak var pickTaskDate:UIDatePicker!
    @IBOutlet weak var pickEndDate:UIDatePicker!
    @IBOutlet weak var pickAlarmTime:UIDatePicker!
    //
    @IBOutlet weak var labelNoRepeat:UILabel!
    @IBOutlet weak var labelFirst:UILabel!
    @IBOutlet weak var labelSecond:UILabel!
    @IBOutlet weak var labelThird:UILabel!
    @IBOutlet weak var labelNoEndDate:UILabel!
    @IBOutlet weak var labelNoAlarm:UILabel!
    //
    @IBOutlet weak var btnPullCategory:UIButton!
    @IBOutlet weak var btnFirst:UIButton!
    @IBOutlet weak var btnSecond:UIButton!
    @IBOutlet weak var btnBack: UIButton!
    //
    @IBOutlet weak var switchRepeat:UISwitch!
    @IBOutlet weak var switchAlarm:UISwitch!
    
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
    private var keyboardHeight:CGFloat?
    private var isShow = false
    //View 관련
    private var resultViewSize:CGSize?
    private var resultViewConstraint:NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.navigationItem.setHidesBackButton(true, animated: false)
        //
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        SystemManager.shared.openLoading()
        //
        scrollView.isScrollEnabled = false
        //날짜 지정
        pickTaskDate.setDate(currntDate, animated: false)
        //
        setDefaultView()
        //키보드 기본세팅
        observeKeyboard()
        //모드에 맞게 세팅
        changeMode()
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
        pickEndDate.overrideUserInterfaceStyle = .dark
        pickAlarmTime.overrideUserInterfaceStyle = .dark
        //
        popView.backgroundColor = .clear
        textView.backgroundColor = .clear
        //
        btnBack.setImage(UIImage(systemName: "chevron.backward", withConfiguration: imageConfig), for: .normal)
        btnBack.tintColor = .systemBackground
        //
        switchRepeat.onTintColor = .systemIndigo
        switchAlarm.onTintColor = .systemIndigo
    }
    //
    private func changeMode() {
        switch currentMode {
        case .LOOK:
            //
            controllEditMode(false)
            //
            loadData()
        case .MODIFY:
            //
            controllEditMode(true)
            //
            loadCategory()
            loadData()
        default:
            //
            inputTitle.attributedPlaceholder = NSAttributedString(string: "TODO를 입력해주세요", attributes: [NSAttributedString.Key.foregroundColor : UIColor.opaqueSeparator])
            switchRepeat.isOn = false
            labelNoRepeat.isHidden = true
            pickEndDate.isEnabled = false
            labelNoEndDate.isHidden = true
            switchAlarm.isOn = false
            pickAlarmTime.isEnabled = false
            pickAlarmTime.isHidden = true
            labelNoAlarm.isHidden = false
            pickAlarmTime.date = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
            //
            printResultView()
            controllReusltView(false)
            //
            loadCategory()
        }
        //
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            SystemManager.shared.closeLoading()
        }
    }
    //
    private func setDefaultView() {
        //기존 사이즈 저장
        resultViewSize = resultView.frame.size
        //
        pickEndDate.isEnabled = false
        controllEditMode(false)
        controllResultView(false)
        //
        resultView.translatesAutoresizingMaskIntoConstraints = false
        resultViewConstraint = resultView.constraints.first { item in
            return item.identifier == "resultViewHeight"
        }
    }
    //
    private func loadData() {
        guard let taskData = taskData else {
            return
        }
        inputTitle.text = taskData.title
        btnPullCategory.setTitle(taskData.category, for: .normal)
        let color = RealmManager.shared.getCategoryColor(taskData.category)
        btnPullCategory.tintColor = color
        btnPullCategory.backgroundColor = color
        pickTaskDate.date = Utils.dateStringToDate(taskData.taskDay)!
        //
        let repeatType = RepeatType(rawValue: taskData.repeatType)!
        let option = taskData.optionData ?? OptionData()
        let isEnd = option.isEnd
        let taskEndDate = option.taskEndDate
        let isAlarm = option.isAlarm
        let alarmTime = option.alarmTime
        repeatResult = RepeatResult(repeatType: repeatType, weekDay: option.getWeekDayList(), weekOfMonth: option.weekOfMonth, isEnd: isEnd, endDate: Utils.dateStringToDate(taskEndDate))
        //
        setResultView(repeatType, isResult: false)
        pickEndDate.isHidden = !isEnd
        labelNoEndDate.isHidden = isEnd
        if isEnd {
            pickEndDate.date = Utils.dateStringToDate(taskEndDate)!
        }
        switchAlarm.isOn = isAlarm
        pickAlarmTime.isHidden = !isAlarm
        labelNoAlarm.isHidden = isAlarm
        if isAlarm {
            pickAlarmTime.date = Utils.stringToDate("\(taskData.taskDay)_\(alarmTime):00")!
        }
        textView.text = taskData.memo
    }
    //카테고리 로드
    private func loadCategory() {
        //
        let funcLoadCategory:()->Void = self.loadCategory
        var categoryList:[UIAction] = []
        let categories = RealmManager.shared.loadCategory()
        for category in categories {
            let image =  category.loadImage()
            categoryList.append(UIAction(title: category.title, image: image, handler: { _ in
                self.btnPullCategory.setTitle(category.title, for: .normal)
                self.btnPullCategory.tintColor = category.loadColor()
                self.btnPullCategory.backgroundColor = category.loadColor()
            }))
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
        categoryList.append(addCategory)
        btnPullCategory.menu = UIMenu(title: "카테고리", children: categoryList)
    }
}

//MARK: - controll
extension TaskInfoViewController {
    //resultView 컨트롤
    private func controllReusltView(_ isOpen:Bool) {
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
    //resultView 결과
    private func showResult(_ result:RepeatResult) {
        repeatResult = result
        //종료일
        guard let repeatResult = repeatResult else {
            return
        }
        pickEndDate.isHidden = !repeatResult.isEnd
        labelNoEndDate.isHidden = repeatResult.isEnd
        if result.isEnd {
            guard let date = repeatResult.taskEndDate else {
                return
            }
            pickEndDate.date = date
        }
        controllReusltView(true)
        //반복 주기
        setResultView(repeatResult.repeatType, isResult: true)
    }
    //
    private func controllEditMode(_ isOn:Bool) {
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
    private func controllResultView(_ isOpen:Bool) {
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
    //
    private func setResultView(_ repeatType:RepeatType, isResult:Bool) {
        //
        var weekDay:String
        var day:String
        var weekOfMonth:String
        //
        if let repeatResult = repeatResult {
            weekDay = repeatResult.getWeekDay()
            day = String(Utils.dateToDateString(pickTaskDate.date).split(separator: "-")[2])
            weekOfMonth = Utils.getWeekOfMonthInKOR(repeatResult.weekOfMonth)
            
        } else {
            guard let taskData = taskData else {
                return
            }
            let option = taskData.optionData ?? OptionData()
            weekDay = taskData.printWeekDay()
            day = String(taskData.taskDay.split(separator: "-")[2])
            weekOfMonth = Utils.getWeekOfMonthInKOR(option.weekOfMonth)
        }
        //
        switch repeatType  {
        case .EveryDay:
            printResultView("매일")
            switchRepeat.isOn = true
            labelNoRepeat.text = ""
            //
            controllReusltView(true)
        case .Eachweek:
            printResultView("매 주", weekDay, "요일")
            switchRepeat.isOn = true
            labelNoRepeat.text = ""
            //
            controllReusltView(true)
        case .EachOnceOfMonth:
            printResultView("매 월", day, "일")
            switchRepeat.isOn = true
            labelNoRepeat.text = ""
            //
            controllReusltView(true)
        case .EachWeekOfMonth:
            printResultView("매 월", weekOfMonth, "주, ", weekDay, "요일")
            switchRepeat.isOn = true
            labelNoRepeat.text = ""
            //
            controllReusltView(true)
        case .EachYear:
            printResultView("매 년", day, "일")
            switchRepeat.isOn = true
            labelNoRepeat.text = ""
            //
            controllReusltView(true)
        default:
            //
            printResultView()
            switchRepeat.isOn = false
            labelNoRepeat.text = "없음"
            //
            controllReusltView(false)
        }
    }
    //result setting
    private func printResultView() {
        labelFirst.isHidden = true
        labelSecond.isHidden = true
        labelThird.isHidden = true
        btnFirst.isHidden = true
        btnSecond.isHidden = true
    }
    private func printResultView(_ thrid:String) {
        labelFirst.isHidden = true
        labelSecond.isHidden = true
        labelThird.isHidden = false
        labelThird.text = thrid
        //
        btnFirst.isHidden = true
        btnSecond.isHidden = true
    }
    private func printResultView(_ second:String, _ btnsecond:String, _ thrid:String) {
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
    private func printResultView(_ first:String, _ btnfirst:String, _ second:String, _ btnsecond:String, _ thrid:String) {
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
        if !pickEndDate.isHidden && taskDay == Utils.dateToDateString(pickEndDate.date) {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "시작일과 종료일이 같을 수 없습니다.")
            return nil
        }
        //
        SystemManager.shared.openLoading()
        //반복 내용 가져오기
        var repeatType = RepeatType.None
        var weekDay = [Bool](repeating: false, count: 7)
        var weekOfMonth = 0
        if switchRepeat.isOn {
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
            data = EachTask(taskDay: pickTaskDate.date, category: category, time: "", title: title, memo: textView.text!, repeatType: repeatType.rawValue)
            let option = OptionData(taskId: data.taskId, weekDay: weekDay, weekOfMonth: weekOfMonth)
            data.setOptionData(option)
        case .MODIFY:
            guard let taskData = taskData else {
                return nil
            }
            let option = OptionData(taskId: taskData.taskId, weekDay: weekDay, weekOfMonth: weekOfMonth)
            data = EachTask(id:taskData.taskId, taskDay: pickTaskDate.date, category: category, time: "", title: title, memo: textView.text!, repeatType: repeatType.rawValue, optionData: option)
            data.setOptionData(option)
        default:
            break
        }
        if !pickEndDate.isHidden {
            data.setEndDate(pickEndDate.date)
        }
        //알람 확인
        if switchAlarm.isOn {
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
        switchRepeat.isOn = false
        offRepeat()
    }
    @IBAction func clickBack(_ sender:Any) {
        guard let navigation = self.navigationController as? CustomNavigationController else {
            return
        }
        navigation.popViewController()
    }
}

//MARK: - 스위치 이벤트
extension TaskInfoViewController {
    //반복토글
    @IBAction func toggleRepeat(_ sender: UISwitch) {
        if sender.isOn {
            //RepeatView열기
            let board = UIStoryboard(name: repeatBoard, bundle: nil)
            guard let repeatVC = board.instantiateViewController(withIdentifier: repeatBoard) as? RepeatViewController else {
                return
            }
            //
            repeatVC.pickDate = pickTaskDate.date
            repeatVC.clickOk = showResult(_:)
            repeatVC.clickCancel = { self.switchRepeat.isOn = false }
            repeatVC.modalPresentationStyle = .overCurrentContext
            repeatVC.modalTransitionStyle = .crossDissolve
            
            present(repeatVC, animated: true)
        } else {
            offRepeat()
        }
    }
    private func offRepeat() {
        printResultView()
        repeatResult = nil
        controllReusltView(false)
    }
    //알람토글
    @IBAction func toggleAlarm(_ sender: UISwitch) {
        //알람 활성화, 비활성화
        pickAlarmTime.isEnabled = sender.isOn
        pickAlarmTime.isHidden = !sender.isOn
        labelNoAlarm.isHidden = sender.isOn
    }
}

//MARK: - 키보드
extension TaskInfoViewController {
    //키보드 옵저버
    private func observeKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //키보드 show/hide시 view 조정
    @objc func showKeyboard(_ sender: Notification) {
        if isShow {
            return
        }
        isShow = true
        let userInfo:NSDictionary = sender.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectabgle = keyboardFrame.cgRectValue
        keyboardHeight = keyboardRectabgle.height
        //
        guard let keyboardHeight = keyboardHeight else {
            return
        }
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.isScrollEnabled = true
    }
    @objc func hideKeyboard(_ sender: Notification) {
        //
        scrollView.contentInset.bottom = 0
        scrollView.isScrollEnabled = false
        isShow = false
    }
    //키보드 내리기
    private func keyboardDown() {
        self.view.endEditing(true)
        isShow = false
    }
}
