//
//  Help.swift
//  TodayTODO
//
//  Created by 소하 on 2022/12/09.
//

import UIKit
import Gifu

class Help: UIView {
    @IBOutlet weak var textInfo: UITextView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnRepeat: UIButton!
    @IBOutlet weak var pageView: UIStackView!
    @IBOutlet weak var page1: UIButton!
    @IBOutlet weak var page2: UIButton!
    @IBOutlet weak var page3: UIButton!
    @IBOutlet weak var page4: UIButton!
    @IBOutlet weak var page5: UIButton!
    @IBOutlet weak var popView: UIView!
    
    var controllTabBar:((Bool)->Void)?
    var openPromotion:(()->Void)?
    let helpDic:[String:[HelpType]] = [TODOBoard:[.MainLeftSwipe, .MainRightSwipe, .MainToday],
                                   CategoryBoard:[.CategoryMove, .CategorySwipe],
                                       PushBoard:[.PushEdit, .PushSwipe]]
    var helpList:[HelpType] = []
    var infoList:[HelpType:String] = [.MainRightSwipe:"TODO를 오른쪽으로 스와이프 하면\n완료 표기를 할 수 있습니다",
                                      .MainLeftSwipe:"TODO를 왼쪽으로 스와이프 하면\n삭제 할 수 있습니다",
                                      .MainSort:"정렬 기준을 선택하여\n정렬 할 수 있습니다",
                                      .MainToday:"표적 모양 아이콘을 통해\n오늘의 날짜로 바로 이동할 수 있습니다",
                                      .CategoryMove:"EDIT를 누른 후 카테고리를 움직여\n우선순위를 수정할 수 있습니다",
                                      .CategorySwipe:"카테고리를 왼쪽으로 스와이프하면\n수정 및 삭제 할 수 있습니다",
                                      .PushEdit:"EDIT를 누르면 편집 모드가 되어\n하단의 버튼을 사용할 수 있습니다",
                                      .PushSwipe:"알람을 왼쪽으로 스와이프하면\n[알림만] 삭제 할 수 있습니다"]
    var btnList:[UIButton] = []
    var gifImgView:GIFImageView?
    var pageIndex = 0
    var boardName = ""
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //
        initailize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //
        initailize()
    }
    
    func initailize() {
        self.backgroundColor = .clear
    }
    
    func setView(_ boardName:String) {
        initUI()
        self.boardName = boardName
        guard let list = helpDic[boardName] else { return }
        helpList = list
        
        for i in 0..<btnList.count {
            btnList[i].isHidden = i < helpList.count ? false : true
        }
        addGIF()
        initGesture()
        playPage()
    }
    
    private func initUI() {
        // 배경 설정
        let backgroundView = UIImageView(frame: popView.bounds)
        backgroundView.image = UIImage(named: PopBackImage)
        popView.insertSubview(backgroundView, at: 0)
        popView.clipsToBounds = true
        //그림자
        popView.layer.shadowColor = UIColor.label.withAlphaComponent(0.4).cgColor
        popView.layer.shadowOpacity = 1
        popView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        //
        textInfo.isEditable = false
        textInfo.isSelectable = false
        textInfo.backgroundColor = .clear
        //
        btnBack.backgroundColor = .clear
        btnRepeat.setTitleColor(.white, for: .normal)
        btnRepeat.tintColor = .white
        btnClose.tintColor = .white
        btnClose.setImage(UIImage(systemName: "xmark")?.withConfiguration(mediumConfig), for: .normal)
        btnRepeat.titleLabel?.font = UIFont(name: K_Font_R, size: K_FontSize - 2.0)
        //
        btnList.append(page1)
        btnList.append(page2)
        btnList.append(page3)
        btnList.append(page4)
        btnList.append(page5)
    }
    
    private func addGIF() {
        gifImgView = GIFImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        guard let gifImgView = gifImgView else { return }
        gifImgView.layer.cornerRadius = 5
        gifImgView.clipsToBounds = true
        popView.addSubview(gifImgView)
        //
        gifImgView.translatesAutoresizingMaskIntoConstraints = false
        gifImgView.leadingAnchor.constraint(equalTo: popView.leadingAnchor, constant: 24).isActive = true
        gifImgView.trailingAnchor.constraint(equalTo: popView.trailingAnchor, constant: -24).isActive = true
        gifImgView.topAnchor.constraint(equalTo: popView.topAnchor, constant: 18).isActive = true
        gifImgView.bottomAnchor.constraint(equalTo: textInfo.topAnchor, constant: -12).isActive = true
    }
    //GIF 재생 및 설명 변경
    private func playPage() {
        pageCheck()
        //
        guard let gifImgView = gifImgView else { return }
        let title = helpList[pageIndex].rawValue
        gifImgView.animate(withGIFNamed: title)
        let text = infoList[helpList[pageIndex]] ?? ""
        let font = UIFont(name: K_Font_B, size: K_FontSize) ?? UIFont()
        textInfo.setLineSpacing(text, font: font, color: .white, align: .center)
    }
    
    private func initGesture() {
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(nextPage))
        leftSwipeGesture.direction = .left
        self.addGestureRecognizer(leftSwipeGesture)
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(prevPage))
        rightSwipeGesture.direction = .right
        self.addGestureRecognizer(rightSwipeGesture)
    }
    @objc func prevPage() {
        if pageIndex == 0 {
            return
        }
        pageIndex -= 1
        //anim
        guard let gifImgView = gifImgView else { return }
        let slideInFromLeftTransition = CATransition()
        slideInFromLeftTransition.type = CATransitionType.moveIn
        slideInFromLeftTransition.subtype = CATransitionSubtype.fromLeft
        slideInFromLeftTransition.duration = 0.5
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        slideInFromLeftTransition.fillMode = CAMediaTimingFillMode.removed
        gifImgView.layer.add(slideInFromLeftTransition, forKey: nil)
        //
        playPage()
    }
    @objc func nextPage() {
        if pageIndex == helpList.count-1 {
            return
        }
        pageIndex += 1
        //anim
        guard let gifImgView = gifImgView else { return }
        let slideInFromLeftTransition = CATransition()
        slideInFromLeftTransition.type = CATransitionType.moveIn
        slideInFromLeftTransition.subtype = CATransitionSubtype.fromRight
        slideInFromLeftTransition.duration = 0.5
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        slideInFromLeftTransition.fillMode = CAMediaTimingFillMode.removed
        gifImgView.layer.add(slideInFromLeftTransition, forKey: nil)
        //
        playPage()
    }
    //페이지 버튼 바꾸기
    private func pageCheck() {
        for i in 0..<helpList.count {
            btnList[i].tintColor = i == pageIndex ? .lightGray : .darkGray
        }
    }
    
    @IBAction func clickRepeat(_ sender:Any) {
        btnRepeat.isSelected = !btnRepeat.isSelected
        var boardKey = ""
        switch boardName {
        case TODOBoard:
            boardKey = HelpMainKey
        case CategoryBoard:
            boardKey = HelpCategoryKey
        case PushBoard:
            boardKey = HelpPushKey
        default:
            break
        }
        UserDefaults.shared.set(btnRepeat.isSelected, forKey: boardKey)
        btnRepeat.setImage(UIImage(systemName: btnRepeat.isSelected ? "checkmark.square.fill" : "square.fill"), for: .normal)
    }
    
    @IBAction func clickClose(_ sender:Any) {
        guard let controllTabBar = controllTabBar else { return }
        self.removeFromSuperview()
        controllTabBar(true)
        guard let openPromotion = openPromotion else { return }
        openPromotion()
    }
}
