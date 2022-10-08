//
//  LoginViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import RealmSwift
import AuthenticationServices


class LoginViewController: UIViewController {
    private var isAuto:Bool = false
    private var loginType:LoginType = LoginType.None
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //버전체크
        guard #available(iOS 15, *) else {
            PopupManager.shared.openOkAlert(self, title: "알림", msg: "iOS 15이상에서만 사용가능합니다.\n[설정->일반->소프트웨어 업데이트]\n에서 업데이트해주세요.", complete: { _ in
                SystemManager.shared.openSettingMenu()
            })
        }
        //
        isAuto = DataManager.shared.getAuto()
        loginType = DataManager.shared.getLoginType()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //기존에 연동 로그인을 한 경우(로그아웃 클릭 시는 재로그인팔요)
        if isAuto {
            switch loginType {
            case .None:
                reloginProcess()
            default:
                guard let user = Auth.auth().currentUser else {
                    reloginProcess()
                    return
                }
                SystemManager.shared.openLoading(self)
                self.loginSuccess(user)
            }
        }
    }
}


//MARK: - Apple Login
extension LoginViewController : ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
    //재전송 공격을 방지를 위해 암호로 보호된 nonce를 포함
    func appleLogin() {
        let appleIdProvider = ASAuthorizationAppleIDProvider()
        let request = appleIdProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        //nonce 포함
        request.nonce = DataManager.shared.makeSHA()
        
        let authrizationController = ASAuthorizationController(authorizationRequests: [request])
        authrizationController.delegate = self
        authrizationController.presentationContextProvider = self
        authrizationController.performRequests()
    }
    //버튼을 눌렀을 때 Apple 로그인을 모달 시트로 표시하는 함수
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    //연동 성공
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            PopupManager.shared.openOkAlert(self, title: "알림", msg:"로그인 실패\n다시 시도해주세요.")
            return
        }
        
        guard let appleIDToken = appleIdCredential.identityToken else {
            print("Unable to fetch identity token")
            return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
        }
        
        // Initialize a Firebase credential.
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: DataManager.shared.getNonce())
        // Sign in with Firebase.
        Auth.auth().signIn(with: credential) { [self]
            authResult, error in
            guard let result = authResult else {
                if let LoginError = error {
                    let authError = LoginError as NSError
                    if authError.code != AuthErrorCode.secondFactorRequired.rawValue {
                        PopupManager.shared.openOkAlert(self, title: "알림", msg:"로그인 중 오류가 발생하였습니다.")
                    }
                }
                return
            }
            loginType = LoginType.Apple
            
            loginSuccess(result.user)
        }
    }
    //연동 실패
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        PopupManager.shared.openOkAlert(self, title: "알림", msg:"로그인 실패\n\(error)")
    }
}

//MARK: - Google Login
extension LoginViewController {
    func googleLogin() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) {
            user, error in
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                PopupManager.shared.openOkAlert(self, title: "알림", msg:"로그인 실패\n\(String(describing: error))")
                return
            }
            
            //
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { [self]
                authResult, error in
                guard let result = authResult else {
                    if let LoginError = error {
                        let authError = LoginError as NSError
                        if authError.code != AuthErrorCode.secondFactorRequired.rawValue {
                            PopupManager.shared.openOkAlert(self, title: "알림", msg:"로그인 중 오류가 발생하였습니다.")
                        }
                    }
                    return
                }
                loginType = LoginType.Google
                
                loginSuccess(result.user)
            }
        }
    }
}

//MARK: - Button Event
extension LoginViewController {
    @IBAction func clickGoogleLogin(_ sender: Any) {
        loginProcess(LoginType.Google)
    }
    
    @IBAction func clickAppleLogin(_ sender: Any) {
        loginProcess(LoginType.Apple)
    }
}


//MARK: - 기능
extension LoginViewController {
    func loginProcess(_ type:LoginType) {
        switch type {
        case .Google:
            self.googleLogin()
        case .Apple:
            self.appleLogin()
        default:
            self.reloginProcess()
        }
    }
    
    func reloginProcess() {
        PopupManager.shared.openOkAlert(self, title: "알림", msg: "다시 로그인해주시기 바랍니다", complete: { _ in
            DataManager.shared.logout()
            self.viewWillAppear(true)
        })
    }
    
    func loginSuccess(_ auth:FirebaseAuth.User?) {
        guard let auth = auth else {
            return
        }
        
        var uid = ""
        var userEmail = ""
        var userName = ""
        
        //자동 로그인 저장
        self.isAuto = true
        DataManager.shared.setAutoLogin(isAuto)
        //기존 가입 유저인지 확인
        DataManager.shared.checkUID(auth.uid) { isExist in
            if isExist {
                //Firebase에 저장된 데이터 가져오기
                DataManager.shared.loadFirebaseUserData { data in
                    DataManager.shared.setUserData(data.uid, data.email, data.name, LoginType(rawValue: data.loginType) ?? self.loginType)
                    DataManager.shared.setUserNickName(data.nickName)
                    
                    //main thread
                    DispatchQueue.main.async {
                        self.moveMain()
                    }
                }
            } else {
                uid = auth.uid
                //메일 및 이름 정보 가져오기
                if let email = auth.email {
                    userEmail = email
                }
                if let nickName = auth.displayName {
                    userName = nickName
                }
                //닉네임 없으면 이메일 앞부분
                if userName.isEmpty {
                    userName = String(userEmail.split(separator: "@")[0])
                }
                //유저데이터 세팅
                DataManager.shared.setUserData(uid, userEmail, userName, self.loginType)
                //firebase에 저장
                let user = DataManager.shared.loadUserData()
                DataManager.shared.addUserDataInFirebase(user)
                
                //
                SystemManager.shared.closeLoading()
                //main thread
                DispatchQueue.main.async {
                    self.moveMain()
                }
            }
        }
    }
    //
    func moveMain() {
        let navigationController = self.navigationController as! CustomNavigationController

        let boardMain = UIStoryboard(name: mainBoard, bundle: nil)
        guard let mainVC = boardMain.instantiateViewController(withIdentifier: mainBoard) as? MainViewController else {
            return
        }

        navigationController.modalTransitionStyle = .crossDissolve
        navigationController.modalPresentationStyle = .overFullScreen

        navigationController.pushViewControllerWithLoading(mainVC, complete: {
            DataManager.shared.openRealm()
        })
    }
}
