//
//  AddTaskViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit

class AddTaskViewController: UIViewController {
    //Label
    @IBOutlet weak var labelFirst: UILabel!
    @IBOutlet weak var labelSecond:UILabel!
    @IBOutlet weak var labelThird: UILabel!
    @IBOutlet weak var labelNil: UILabel!
    //Input
    @IBOutlet weak var inputTitle:UITextField!
    //DataPicker
    @IBOutlet weak var pickDate:UIDatePicker!
    @IBOutlet weak var pickAlarmTime:UIDatePicker!
    @IBOutlet weak var pickEndDate:UIDatePicker!
    //pullDown
    @IBOutlet weak var pullBtnCategory: UIButton!
    //Button
    @IBOutlet weak var btnFirst: UIButton!
    @IBOutlet weak var btnSecond: UIButton!
    //View
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var textView:UITextView!
    //Switch
    @IBOutlet weak var repeatSwitch:UISwitch!
    @IBOutlet weak var alarmsSwitch:UISwitch!
    //SearchBar
//    @IBOutlet weak var searchPlace:UISearchBar!
    
    //
    var refreshTask:(()->Void)?
    //
    private var repeatResult:RepeatResult?
    //키보드 관련
    private var keyboardHeight:CGFloat?
    private var isShow = false
    //기존 사이즈
    private var resultViewSize:CGSize?
    //constraints
    private var resultViewConstraint:NSLayoutConstraint?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        self.navigationItem.setHidesBackButton(true, animated: false)
        //기존 사이즈 저장
        resultViewSize = resultView.frame.size
        //기본세팅
        observeKeyboard()
        setTapGesture()
        //UI로딩
        loadUI()
        //Loading
        SystemManager.shared.closeLoading()
    }
}


//MARK: - UI
extension AddTaskViewController {
    //처음 로드 시 UI default값 세팅
    func loadUI() {
        //초기세팅
        setDefaultView()
        setDateView()
        setAlarmView()
        //default 시간 세팅
        pickAlarmTime.date = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        //카테고리 로딩
        loadCategory()
        //서치바 세팅
//        setSearchBar()
    }
    func setDateView() {
        //
        setResult()
        labelNil.isHidden = true
        repeatSwitch.isOn = false
        pickEndDate.isEnabled = false
        controllReusltView(false)
    }
    func setAlarmView() {
        //
        alarmsSwitch.isOn = false
        pickAlarmTime.isEnabled = false
    }
    //searchBar 세팅
//    func setSearchBar() {
//        searchPlace.placeholder = "장소를 추가하세요"
//        searchPlace.searchTextField.backgroundColor = UIColor.clear
//        searchPlace.searchTextField.font = UIFont.systemFont(ofSize: 15)
//        searchPlace.searchTextField.borderStyle = .none
//        searchPeople.placeholder = "사람을 추가하세요"
//        searchPeople.searchTextField.backgroundColor = UIColor.clear
//        searchPeople.searchTextField.font = UIFont.systemFont(ofSize: 15)
//        searchPeople.searchTextField.borderStyle = .none
//    }
    //View 세팅
    func setDefaultView() {
        resultView.translatesAutoresizingMaskIntoConstraints = false
        resultViewConstraint = resultView.constraints.first { item in
            return item.identifier == "resultViewHeight"
        }
    }
    //카테고리 로드
    func loadCategory() {
        var categoryList:[UIAction] = []
        let defaltCategory = UIAction(title: "Default", handler: { _ in
            self.pullBtnCategory.setTitle("Default", for: .normal)
            self.pullBtnCategory.setImage(UIImage(), for: .normal)
        })
        categoryList.append(defaltCategory)
        
        //사용자 카테고리
        let categories = DataManager.shared.loadCategory()
        if let categories = categories {
            for category in categories {
                let image =  category.loadImage()
                categoryList.append(UIAction(title: category.title, image: image, handler: { _ in
                    self.pullBtnCategory.setTitle("     \(category.title)", for: .normal)
                    self.pullBtnCategory.setImage(image, for: .normal)
                }))
            }
        }
        //카테고리 추가 버튼
        let addCategory = UIAction(title: "카테고리 추가", attributes: .destructive, handler: { _ in
            let board = UIStoryboard(name: categoryBoard, bundle: nil)
            guard let colorVC = board.instantiateViewController(withIdentifier: categoryBoard) as? CategoryViewController else { return }
            
            colorVC.modalTransitionStyle = .coverVertical
            colorVC.modalPresentationStyle = .pageSheet
            colorVC.reloadCategory = self.loadCategory
            
            self.present(colorVC, animated: true)
        })
        categoryList.append(addCategory)
        
        pullBtnCategory.menu = UIMenu(title: "카테고리", children: categoryList)
    }
    //result setting
    func setResult() {
        labelFirst.isHidden = true
        labelSecond.isHidden = true
        labelThird.isHidden = true
        //
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
extension AddTaskViewController {
    //등록버튼
    @IBAction func clickSubmit(_ sender: Any) {
        //제목검토
        guard let title = inputTitle.text else {
            return
        }
        if title.isEmpty {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "타이틀을 입력해주세요")
            return
        }
        //카테고리 검토
        guard let category = pullBtnCategory.currentTitle else {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "카테고리를 선택해주세요")
            return
        }
        //종료일 검토
        let taskDay = Utils.dateToDateString(pickDate.date)
        if !pickEndDate.isHidden && taskDay == Utils.dateToString(pickEndDate.date) {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "시작일과 종료일이 같을 수 없습니다.")
            return
        }
        //반복 내용 가져오기
        var repeatType = RepeatType.None
        var weekDay = [Bool](repeating: false, count: 7)
        var monthOfWeek = MonthOfWeek.None
        if repeatSwitch.isOn {
            //RepeatResult 내용 가져오기
            guard let repeatResult = repeatResult else {
                return
            }
            repeatType = repeatResult.repeatType
            weekDay = repeatResult.weekDay
            monthOfWeek = repeatResult.monthOfWeek
        }
        //태스크 생성
        let data = EachTask(taskDay: pickDate.date, category: category, title: title, memo: textView.text!, repeatType: repeatType.rawValue, weekDay: weekDay, monthOfWeek: monthOfWeek.rawValue)
        if !pickEndDate.isHidden {
            data.setEndDate(pickEndDate.date)
        }
        //알람 확인
        if alarmsSwitch.isOn {
            data.setAlarm(pickAlarmTime.date)
        }
        //realm에 추가
        DataManager.shared.addTaskData(data)
        //
        DispatchQueue.main.async {
            self.refreshTask?()
            let navigation = self.navigationController as! CustomNavigationController
            navigation.popViewController()
        }
    }
    //
    @IBAction func clickCancel(_ sender: Any) {
        let navigation = self.navigationController as! CustomNavigationController
        navigation.popViewController()
    }
    //
    @IBAction func changeTime(_ sender: UIDatePicker) {
        print(Utils.dateToTimeString(sender.date))
    }
}

//MARK: - 스위치 이벤트
extension AddTaskViewController {
    //반복토글
    @IBAction func toggleRepeat(_ sender: UISwitch) {
        if sender.isOn {
            //RepeatView열기
            let board = UIStoryboard(name: repeatBoard, bundle: nil)
            guard let repeatVC = board.instantiateViewController(withIdentifier: repeatBoard) as? RepeatViewController else {
                return
            }
            repeatVC.taskDay = Utils.dateToString(pickDate.date)
            repeatVC.clickOk = showResult(_:)
            repeatVC.clickCancel = { self.repeatSwitch.isOn = false }
            repeatVC.modalPresentationStyle = .overCurrentContext
            repeatVC.modalTransitionStyle = .crossDissolve
            
            present(repeatVC, animated: true)
        } else {
            setResult()
            repeatResult = nil
            controllReusltView(false)
        }
    }
    //알람토글
    @IBAction func toggleAlarms(_ sender: UISwitch) {
        //알람 활성화, 비활성화
        pickAlarmTime.isEnabled = sender.isOn
    }
}

//MARK: - View Controll
extension AddTaskViewController {
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
    //스크롤 이동
    func moveScroll(_ isUp:Bool) {
        let point = CGPoint(x: 0, y: isUp ? 0 : scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(point, animated: true)
    }
    //resultView 결과
    func showResult(_ result:RepeatResult) {
        repeatResult = result
        //종료일
        guard let repeatResult = repeatResult else {
            return
        }
        pickEndDate.isHidden = !repeatResult.isEnd
        labelNil.isHidden = repeatResult.isEnd
        if result.isEnd {
            guard let date = repeatResult.taskEndDate else {
                return
            }
            pickEndDate.date = date
        }
        controllReusltView(true)
        //반복 주기
        switch repeatResult.repeatType {
        case .EveryDay:
            setResult("매일")
        case .Eachweek:
            setResult("매 주", repeatResult.getWeekDay(), "요일")
        case .EachMonthOfOnce:
            setResult("매 월", String(Utils.dateToDateString(pickDate.date).split(separator: "-")[2]), "일")
        case .EachMonthOfWeek:
            setResult("매 월", String(repeatResult.monthOfWeek.rawValue), "주, ", repeatResult.getWeekDay(), "요일")
        case .EachYear:
            setResult("매 년", String(Utils.dateToDateString(pickDate.date).split(separator: "-")[2]), "일")
        default:
            setResult()
        }
    }
}

//MARK: - 키보드
extension AddTaskViewController {
    //키보드 옵저버
    func observeKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //탭 제스쳐 설정 어디서든 1번 탭 할 경우 키보드 내리기
    func setTapGesture() {
        let basicViewsingleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(basicViewSingleTap(_:)))
        basicViewsingleTapGestureRecognizer.numberOfTapsRequired = 1
        basicViewsingleTapGestureRecognizer.isEnabled = true
        basicViewsingleTapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(basicViewsingleTapGestureRecognizer)
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
        scrollView.contentInset.bottom = keyboardHeight!
        moveScroll(false)
    }
    @objc func hideKeyboard(_ sender: Notification) {
        moveScroll(true)
        isShow = false
    }
    //키보드 내리기
    func keyboardDown() {
        self.view.endEditing(true)
        isShow = false
    }
    //
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard let height = keyboardHeight else {
            return
        }
        scrollView.contentInset.bottom = height
    }
    //scrollView SingleTouch
    @objc func basicViewSingleTap(_ sender: UITapGestureRecognizer) {
        keyboardDown()
    }
}
