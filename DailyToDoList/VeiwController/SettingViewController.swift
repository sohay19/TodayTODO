//
//  SettingViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit
import FirebaseAuth

class SettingViewController: UIViewController {
    @IBOutlet weak var labelNickName: UILabel!
    @IBOutlet weak var labelBackupDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //유저닉네임 가져오기
        let userData = DataManager.shared.loadUserData()
        labelNickName.text = userData.nickName
        //백업파일 날짜로드
        DataManager.shared.updateCloud(label: labelBackupDate)
        SystemManager.shared.closeLoading()
    }
}


//MARK: - Func
extension SettingViewController {
    //닉네임 수정완료 시
    func changeNickName(_ nick:String) {
        DataManager.shared.modifyNickName(nick)
    }
    
    func userLogout() {
        let loginType = DataManager.shared.getLoginType()
        //로컬 데이터 초기화
        DataManager.shared.logout()
        //로그아웃
        switch loginType {
        case .None:
            break
        default:
            let auth = Auth.auth()
            do {
                try auth.signOut()
            } catch let signOutError as NSError {
                PopupManager.shared.openOkAlert(self, title: "알림", msg: "로그아웃 중 오류가 발생헀습니다.\n다시 시도해주시기 바랍니다\n\(signOutError)") { _ in
                    return
                }
            }
        }
        let navigation = self.navigationController as! CustomNavigationController
        navigation.popToRootViewController()
    }
}

//MARK: - Button Event
extension SettingViewController {
    //닉네임 수정
    @IBAction func ModifyNickName(_ sender: Any) {
        PopupManager.shared.openNickPopup(self, title: "닉네임 입력", msg: "변경하실 닉네임을 입력해주세요.", labelNick: labelNickName, complete: { _ in
            self.changeNickName(self.labelNickName.text!)
        })
    }
    //데이터 백업
    @IBAction func backData(_ sender: Any) {
        DataManager.shared.iCloudBackup(self)
    }
    //데이터 로드
    @IBAction func loadData(_ sender: Any) {
        DataManager.shared.iCloudLoadFile(self)
    }
    //로그아웃
    @IBAction func clickLogout(_ sender: Any) {
        userLogout()
    }
    //탈퇴
    @IBAction func deleteAccount(_ sender: Any) {
        PopupManager.shared.openYesOrNo(self, title: "탈퇴하시겠습니까?", msg: "Apple 연동 로그인의 경우\n아래 절차가 추가로 필요합니다.", completeYes: { _ in
            //firebase 데이터 삭제
            DataManager.shared.deleteAccount(self)
            //로그아웃
            self.userLogout()
        })
    }
    //refresh
    @IBAction func clickRefresh(_ sender: Any) {
        DataManager.shared.updateCloud(label: labelBackupDate)
    }
    
    @IBAction func removeBackupFile(_ sender: Any) {
        DataManager.shared.deleteiCloudBackupFile()
    }
}
