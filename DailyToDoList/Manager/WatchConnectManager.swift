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
    func sendToWatchTask(_ complete: @escaping () -> Void) {
        if !session.isReachable {
            print("isReachable = \(session.isReachable)")
            return
        }
        RealmManager.shared.getTaskDataForDay(date: Date()) { founData in
            var taskList:[NSEachTask] = []
            for data in founData {
                taskList.append(NSEachTask.init(task: data))
            }
            sendWatch(taskList, complete)
        }
    }
    
    func sendWatch(_ sendData:[NSEachTask], _ compelete: @escaping () -> Void) {
        let curruntTime = CFAbsoluteTimeGetCurrent()
        //너무 빨리 재전송 막기
        if lastWatchMsg + 0.5 > curruntTime {
            return
        }
        do {
            let sendData = try NSKeyedArchiver.archivedData(withRootObject: sendData, requiringSecureCoding: false)
            session.sendMessageData(sendData) { data in
                do {
                    guard let receiveData:[NSEachTask] = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [NSEachTask] else { return }
                    print("receiveData = \(receiveData.count)")
                    //
                    compelete()
                } catch {
                    print("Decoding Error")
                }
            } errorHandler: { error in
                print("send Error")
            }
        } catch {
            print("Encoding Error")
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
