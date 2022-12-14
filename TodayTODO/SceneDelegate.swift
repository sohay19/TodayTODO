//
//  SceneDelegate.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/08.
//

import UIKit
import WidgetKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        //네비게이션 컨트롤러 설정
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        //root = tabBoard
        let rootBoard = UIStoryboard(name: MainBoard, bundle: nil)
        guard let mainVC = rootBoard.instantiateViewController(withIdentifier: MainBoard) as? MainViewController else { return }
        let navigationController = CustomNavigationController(rootViewController: mainVC)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        //앱 접속 시 푸시 알림 뱃지 카운트 초기화
        UIApplication.shared.applicationIconBadgeNumber = 0
        DataManager.shared.removeBadgeCnt()
        
        //오늘 날짜 확인
        let today = DataManager.shared.getToday()
        let currentToday = Utils.dateToDateString(Date())
        if today.isEmpty || currentToday != today {
            DataManager.shared.setPromotion(false)
            DataManager.shared.setToday(currentToday)
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
        // 위젯 새로고침
        WidgetCenter.shared.reloadAllTimelines()
        //업데이트 용
        DataManager.shared.copyRealm()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // 위젯 새로고침
        WidgetCenter.shared.reloadAllTimelines()
    }
}

