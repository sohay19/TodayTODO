//
//  AppDelegate.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit
import GoogleSignIn
import RealmSwift
import FirebaseCore
import FirebaseMessaging
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Firabase 설정
        FirebaseApp.configure()
        //메인 로딩을 위해 Realm 세팅
        DataManager.shared.setRealm()
        //로컬 푸시 설정
        UNUserNotificationCenter.current().delegate = self
        //노티 권한 및 옵션 설정
        let notiAuthOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
        UNUserNotificationCenter.current().requestAuthorization(options: notiAuthOptions) { success, error in
            if let error = error {
                print("Permission Error = \(error)")
                return
            }
            //
            let action = UNNotificationAction(identifier: "modal", title: "Today TODO")
            let category = UNNotificationCategory(identifier: appName, actions: [action], intentIdentifiers: [])
            UNUserNotificationCenter.current().setNotificationCategories([category])
            //
            DispatchQueue.main.async {
                //APNS 등록
                application.registerForRemoteNotifications()
            }
        }
        //원격 푸시 설정
        Messaging.messaging().delegate = self
        //워치 커넥팅을 위한 세선 열기
        WatchConnectManager.shared.initSession()
        //애드몹 초기화
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        // 폰트 세팅
        let font = DataManager.shared.getFont()
        DataManager.shared.setFont(font)
        // 테마 세팅
        let theme = DataManager.shared.getTheme()
        DataManager.shared.setTheme(theme)

        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    //
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    //APNS 등록 성공 시
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNS에 앱 등록 성공")
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if error != nil {
                print("messaging token 등록 Error :: \(String(describing: error))")
                return
            }
        }
    }
    //APNS 등록 실패 시
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNS에 앱 등록 실패")
        #if !targetEnvironment(simulator)
        DispatchQueue.main.async {
            PopupManager.shared.openOkAlert(application.topViewController()!, title: "알림", msg: "앱을 다시 실행해주세요.") { _ in
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    exit(0)
                }
            }
        }
        #endif
    }
    
    //Silent Push
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Silent Push Notification")
    }
}

//MARK: - 로컬 푸시
extension AppDelegate : UNUserNotificationCenterDelegate {
    //foreground 상태
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        guard let pushType = userInfo[pushTypeKey] as? String else {
            return
        }
        print("[pushType :: \(pushType)]")
        
        switch PushType(rawValue: pushType) {
        case .Alert:
            completionHandler([.banner, .list, .badge, .sound])
        default:
            completionHandler([.banner, .list, .badge, .sound])
        }
    }
    
    //background 상태에서 받은 후 실행
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        guard let pushType = userInfo[pushTypeKey] as? String else {
            return
        }
        print("[pushType :: \(pushType)]")
        
        switch PushType(rawValue: pushType) {
        case .Alert:
            completionHandler()
        default:
            completionHandler()
        }
    }
}

//MARK: - FCM
extension AppDelegate : MessagingDelegate {
    //
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            print("FCM token is nil")
            return
        }
        // FCM 토큰
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(
            name: .FCMToken,
            object: nil,
            userInfo: dataDict
        )
        //Firebase에 토큰 저장
        FirebaseManager.shared.sendToken(["uuid": SystemManager.shared.getUUID(), "token": fcmToken])
    }
}
