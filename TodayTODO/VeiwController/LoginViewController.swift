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
import AuthenticationServices
import FirebaseMessaging


class LoginViewController: UIViewController {
    private var loginType:LoginType = LoginType.None
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //
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
        request.nonce = FirebaseManager.shared.shaNonce()
        
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
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: FirebaseManager.shared.getNonce())
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

//MARK: - 기능
extension LoginViewController {
    func loginProcess(_ type:LoginType) {
        switch type {
        case .Google:
            self.googleLogin()
        default:
            self.appleLogin()
        }
    }
    
    func loginSuccess(_ auth:FirebaseAuth.User?) {
        guard let auth = auth else {
            return
        }
        print("uid = \(auth.uid)")
        self.loginClear()
    }
    func loginClear() {
        DispatchQueue.main.async {
            //FCM Topic 구독
            Messaging.messaging().subscribe(toTopic: "ALL_USER") { error in
              print("Subscribed to ALL_USER topic")
            }
            //
            SystemManager.shared.closeLoading()
        }
    }
}
