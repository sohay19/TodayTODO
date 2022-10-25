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
    var initWatchTable:(([EachTask])->Void)?
    private var session:WCSession
    
    func initSession() {
        #if os(iOS)
        print("iOS")
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
        #else
        print("watchOS")
        session.delegate = self
        session.activate()
        #endif
    }
}

//MARK: - send
extension WatchConnectManager {
    //
    func requestTask() {
        guard session.activationState == .activated && session.isReachable else {
            print("state = \(session.activationState == .activated ? "activated" : "not activated"), isReachable = \(session.isReachable)")
            return
        }
        //
        print("requestTask")
        session.transferUserInfo(["state":"request"])
    }
    //
    func sendToWatchTask() {
        guard session.activationState == .activated && session.isReachable else {
            print("state = \(session.activationState == .activated ? "activated" : "not activated"), isReachable = \(session.isReachable)")
            return
        }
        //
        print("sendToWatchTask")
        //
        DispatchQueue.main.async {
            RealmManager.shared.getTaskDataForDay(date: Date()) { founData in
                var taskList:[NSEachTask] = []
                for data in founData {
                    taskList.append(NSEachTask.init(task: data))
                }
                do {
                    let dataForWatch = try JSONEncoder().encode(taskList)
//                    let dataForWatch = try NSKeyedArchiver.archivedData(withRootObject: taskList as Array, requiringSecureCoding: false)
                    self.session.sendMessageData(dataForWatch, replyHandler: nil)
                } catch {
                    print("Encoding Error")
                }
            }
        }
    }
}

//MARK: - replyHandler
extension WatchConnectManager {
    func errorHandler(_ error:Error) {
        print("send Error")
    }
}

extension WatchConnectManager : WCSessionDelegate {
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .notActivated:
            print("Session = notActivated")
        case .inactive: //수신 가능, 송신 불가능
            print("Session = inactive")
        case .activated:
            print("Session = activated")
        default:
            break
        }
    }
    //
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("didReceiveUserInfo")
        WatchConnectManager.shared.sendToWatchTask()
    }
    //
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("didReceiveMessage = \(message)")
    }
    //
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        DispatchQueue.main.async { [self] in
            print("didReceiveMessageData")
            do {
                let receiveMsgData = try JSONDecoder().decode(NSEachTaskList.self, from: messageData)                
//                guard let receiveMsgData = try NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClasses: [NSArray.self, NSEachTask.self], from: messageData) as? [NSEachTask] else { return }
                var newTaskList:[EachTask] = []
                for data in receiveMsgData.taskList {
                    newTaskList.append(EachTask(task:data))
                }
                print("taskList.count = \(newTaskList.count)")
                guard let initWatchTable = initWatchTable else {
                    print("initWatchTable is nil")
                    return
                }
                initWatchTable(newTaskList)
            } catch {
                print("Deconding Error")
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        replyHandler(messageData)
    }
}
