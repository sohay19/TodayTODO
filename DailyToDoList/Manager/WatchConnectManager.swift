//
//  WatchConnectManager.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/24.
//

import Foundation
import WatchConnectivity

class WatchConnectManager : NSObject {
    static let shared = WatchConnectManager()
    private override init() {
        session = WCSession.default
    }
    //
    private var session:WCSession
    var lastWatchMsg:CFAbsoluteTime = 0
    
    func initSession() -> Bool {
        if WCSession.isSupported() {
            session = WCSession.default
            session.delegate = self
            session.activate()
            
            return true
        } else {
            return false
        }
    }
}

extension WatchConnectManager {
    func sendWatch() {
        let curruntTime = CFAbsoluteTimeGetCurrent()
        //너무 빨리 재전송 막기
        if lastWatchMsg + 0.5 > curruntTime {
            return
        }
        do {
            let sendData = try NSKeyedArchiver.archivedData(withRootObject: NSEachTask(task: EachTask()), requiringSecureCoding: false)
            session.sendMessageData(sendData) { data in
                print("받은 데이터 = \(data)")
            } errorHandler: { error in
                print("send Error = \(error)")
            }
        } catch {
            print("coding Error")
        }

        //도착함
        lastWatchMsg = CFAbsoluteTimeGetCurrent()
    }
}


extension WatchConnectManager: WCSessionDelegate {
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session DidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("Session DidDeactivate")
    }
    #endif
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session Complete")
    }
}
