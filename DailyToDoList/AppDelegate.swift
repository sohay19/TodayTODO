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


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Firabase 설정
        FirebaseApp.configure()
        //로컬 푸시 설정
        UNUserNotificationCenter.current().delegate = self
        //노티 권한 및 옵션 설정
        PushManager.shared.requestPushPermission()
        //APNS 등록
        application.registerForRemoteNotifications()
        //원격 푸시 설정
        Messaging.messaging().delegate = self
        //
        WatchConnectManager.shared.initSession()
        
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
    //데이터가 있는 원격 푸시
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Silent Push Notification")
        PushManager.shared.checkExpiredPush()
        WatchConnectManager.shared.sendToWatchTask()
    }
}


//MARK: - 로컬 푸시
extension AppDelegate : UNUserNotificationCenterDelegate {
    //foreground 상태
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let data = notification.request.content.userInfo
        print("[foreground :: \(data)]")
        completionHandler([.banner, .list, .badge, .sound])
    }
    //background 상태
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let data = response.notification.request.content.userInfo
        print("[background :: \(data)]")
        completionHandler()
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
        // FCM test 가능 토큰
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        print("FCM token = \(fcmToken)")
        FirebaseManager.shared.sendToken(["uuid": SystemManager.shared.getUUID(), "token": fcmToken])
    }
}
