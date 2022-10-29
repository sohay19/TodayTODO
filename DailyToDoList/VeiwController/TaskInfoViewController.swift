//
//  TaskInfoViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/14.
//

import UIKit


class TaskInfoViewController : UIViewController {
    @IBOutlet weak var popView:UIView!
    @IBOutlet weak var buttonView: UIView!
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
    @IBOutlet weak var btnModify: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    //
    @IBOutlet weak var switchRepeat:UISwitch!
    @IBOutlet weak var switchAlarm:UISwitch!
    
    //
    var taskData:EachTask?
    var repeatResult:RepeatResult?
    var currentMode:TaskMode = .LOOK
    var currntDate:Date = Date()
    //
    var refreshTask:(()->Void)?
    //
    //키보드 관련
    private var keyboardHeight:CGFloat?
    private var isShow = false
    //resultView 관련
    private var resultViewSize:CGSize?
    private var resultViewConstraint:NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        scrollView.isScrollEnabled = false
        //날짜 지정
        pickTaskDate.setDate(currntDate, animated: false)
        //
        setDefaultView()
        loadUI()
        //키보드 기본세팅
        observeKeyboard()
        //모드에 맞게 세팅
        changeMode()
        //Loading
        SystemManager.shared.closeLoading()
    }
}

//MARK: - initialize
extension TaskInfoViewController {
    //
    func changeMode() {
        switch currentMode {
        case .LOOK:
            btnModify.isHidden = false
            btnAdd.isHidden = true
            //
            controllEditMode(false)
            btnModify.setTitle("Modify", for: .normal)
            btnModify.isSelected = false
            //
            loadData()
        case .MODIFY:
            btnModify.isHidden = false
            btnAdd.isHidden = true
            //
            controllEditMode(true)
            btnModify.setTitle("Done", for: .normal)
            btnModify.isSelected = true
            //
            loadCategory()
            //
            loadData()
        default:
            //ADD
            btnModify.isHidden = true
            btnAdd.isHidden = false
            //
            inputTitle.placeholder = "TODO를 입력해주세요"
            loadCategory()
            //
            showResult()
            switchRepeat.isOn = false
            labelNoRepeat.isHidden = true
            pickEndDate.isEnabled = false
            labelNoEndDate.isHidden = true
            //
            switchAlarm.isOn = false
            pickAlarmTime.isEnabled = false
            pickAlarmTime.isHidden = true
            labelNoAlarm.isHidden = false
            pickAlarmTime.date = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
            //
            controllReusltView(false)
        }
    }
    //
    func setDefaultView() {
        resultView.translatesAutoresizingMaskIntoConstraints = false
        resultViewConstraint = resultView.constraints.first { item in
            return item.identifier == "resultViewHeight"
        }
    }
    //
    func loadData() {
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
        repeatResult = RepeatResult(repeatType: repeatType, weekDay: taskData.getWeekDayList(), monthOfWeek: MonthOfWeek(rawValue: taskData.monthOfWeek)!, isEnd: taskData.isEnd, endDate: Utils.dateStringToDate(taskData.taskEndDate))
        //
        setResultView(repeatType, isResult: false)
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
        //기존 사이즈 저장
        resultViewSize = resultView.frame.size
        //모서리 둥글게
        popView.layer.cornerRadius = 10
        buttonView.layer.cornerRadius = 10
        //그림자
        popView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        popView.layer.shadowRadius = 10
        popView.layer.shadowOpacity = 1
        buttonView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        buttonView.layer.shadowRadius = 10
        buttonView.layer.shadowOpacity = 1
        //
        pickEndDate.isEnabled = false
        controllEditMode(false)
        controllResultView(false)
    }
    //카테고리 로드
    func loadCategory() {
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
    //
    func setResultView(_ repeatType:RepeatType, isResult:Bool) {
        //
        var weekDay:String
        var day:String
        var monthOfWeek:String
        //
        if let repeatResult = repeatResult {
            weekDay = repeatResult.getWeekDay()
            day = String(Utils.dateToDateString(pickTaskDate.date).split(separator: "-")[2])
            monthOfWeek = String(repeatResult.monthOfWeek.rawValue)
            
        } else {
            guard let taskData = taskData else {
                return
            }
            weekDay = taskData.printWeekDay()
            day = String(taskData.taskDay.split(separator: "-")[2])
            monthOfWeek = String(taskData.monthOfWeek)
        }
        //
        switch repeatType  {
        case .EveryDay:
            showResult("매일")
            switchRepeat.isOn = true
            labelNoRepeat.text = ""
            //
            controllReusltView(true)
        case .Eachweek:
            showResult("매 주", weekDay, "요일")
            switchRepeat.isOn = true
            labelNoRepeat.text = ""
            //
            controllReusltView(true)
        case .EachMonthOfOnce:
            showResult("매 월", day, "일")
            switchRepeat.isOn = true
            labelNoRepeat.text = ""
            //
            controllReusltView(true)
        case .EachMonthOfWeek:
            showResult("매 월", monthOfWeek, "주, ", weekDay, "요일")
            switchRepeat.isOn = true
            labelNoRepeat.text = ""
            //
            controllReusltView(true)
        case .EachYear:
            showResult("매 년", day, "일")
            switchRepeat.isOn = true
            labelNoRepeat.text = ""
            //
            controllReusltView(true)
        default:
            //
            showResult()
            switchRepeat.isOn = false
            labelNoRepeat.text = "없음"
            //
            controllReusltView(false)
        }
    }
    //result setting
    func showResult() {
        labelFirst.isHidden = true
        labelSecond.isHidden = true
        labelThird.isHidden = true
        btnFirst.isHidden = true
        btnSecond.isHidden = true
    }
    func showResult(_ thrid:String) {
        labelFirst.isHidden = true
        labelSecond.isHidden = true
        labelThird.isHidden = false
        labelThird.text = thrid
        //
        btnFirst.isHidden = true
        btnSecond.isHidden = true
    }
    func showResult(_ second:String, _ btnsecond:String, _ thrid:String) {
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
    func showResult(_ first:String, _ btnfirst:String, _ second:String, _ btnsecond:String, _ thrid:String) {
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
        //반복 내용 가져오기
        var repeatType = RepeatType.None
        var weekDay = [Bool](repeating: false, count: 7)
        var monthOfWeek = MonthOfWeek.None
        if switchRepeat.isOn {
            //RepeatResult 내용 가져오기
            guard let repeatResult = repeatResult else {
                return nil
            }
            repeatType = repeatResult.repeatType
            weekDay = repeatResult.weekDay
            monthOfWeek = repeatResult.monthOfWeek
        }
        //태스크 생성
        var data = EachTask()
        switch currentMode {
        case .ADD:
            data = EachTask(taskDay: pickTaskDate.date, category: category, title: title, memo: textView.text!, repeatType: repeatType.rawValue, weekDay: weekDay, monthOfWeek: monthOfWeek.rawValue)
        case .MODIFY:
            guard let taskData = taskData else {
                return nil
            }
            data = EachTask(id:taskData.id, taskDay: pickTaskDate.date, category: category, title: title, memo: textView.text!, repeatType: repeatType.rawValue, weekDay: weekDay, monthOfWeek: monthOfWeek.rawValue)
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
        guard let data = makeTask() else {
            return
        }
        //realm에 추가
        RealmManager.shared.addTaskDataIniOS(data)
        guard let refreshTask = refreshTask else {
            return
        }
        dismiss(animated: true, completion: refreshTask)
    }
    //수정 Or 완료 버튼
    @IBAction func clickModify(_ sender:UIButton) {
        if currentMode == .LOOK {
            currentMode = .MODIFY
        } else {
            guard let data = makeTask() else {
                print("task is Nil")
                return
            }
            RealmManager.shared.updateTaskDataIniOS(data)
            currentMode = .LOOK
            data.printTask()
        }
        changeMode()
    }
    // 날짜 선택 시 팝업 닫음
    @IBAction func changeDate(_ sender:UIDatePicker) {
        presentedViewController?.dismiss(animated: false)
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
            repeatVC.taskDay = Utils.dateToDateString(pickTaskDate.date)
            repeatVC.clickOk = showResult(_:)
            repeatVC.clickCancel = { self.switchRepeat.isOn = false }
            repeatVC.modalPresentationStyle = .overCurrentContext
            repeatVC.modalTransitionStyle = .crossDissolve
            
            present(repeatVC, animated: true)
        } else {
            showResult()
            repeatResult = nil
            controllReusltView(false)
        }
    }
    //알람토글
    @IBAction func toggleAlarm(_ sender: UISwitch) {
        //알람 활성화, 비활성화
        pickAlarmTime.isEnabled = sender.isOn
        pickAlarmTime.isHidden = !sender.isOn
        labelNoAlarm.isHidden = sender.isOn
    }
}

//MARK: - View Controll
extension TaskInfoViewController {
    //resultView 컨트롤
    func controllReusltView(_ isOpen:Bool) {
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
    func showResult(_ result:RepeatResult) {
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
}

//MARK: - 키보드
extension TaskInfoViewController {
    //키보드 옵저버
    func observeKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @IBAction func clickBackground(_ sender:Any) {
        if isShow {
            keyboardDown()
        } else {
            self.dismiss(animated: true)
        }
    }
    @IBAction func clickPopView(_ sender:Any) {
        if isShow {
            keyboardDown()
        }
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
    func keyboardDown() {
        self.view.endEditing(true)
        isShow = false
    }
}
