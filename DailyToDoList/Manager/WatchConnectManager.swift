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
    var session:WCSession
    
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
    func requestTask(_ index:Int) {
        guard session.activationState == .activated || session.activationState == .inactive else {
            print("activationState is notActivated")
            return
        }
        session.transferUserInfo(["state":"request"])
    }
    //
    func sendToWatchTask() {
        guard session.activationState == .activated || session.activationState == .inactive else {
            print("activationState is notActivated")
            return
        }
        //
        RealmManager.shared.getTaskDataForDay(date: Date()) { founData in
            var taskList:[NSEachTask] = []
            for data in founData {
                taskList.append(NSEachTask.init(task: data))
            }
            do {
                let dataForWatch = try JSONEncoder().encode(NSEachTaskList(taskList: taskList))
                session.transferUserInfo(["task":dataForWatch])
            } catch {
                print("Encoding Error")
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
        #if os(iOS)
        print("didReceiveUserInfo_iOS")
        WatchConnectManager.shared.sendToWatchTask()
        #else
        print("didReceiveUserInfo_watchOS")
        DispatchQueue.main.async { [self] in
            do {
                let receiveMsgData = try JSONDecoder().decode(NSEachTaskList.self, from: userInfo["task"] as! Data)
                var newTaskList:[EachTask] = []
                for data in receiveMsgData.taskList {
                    newTaskList.append(EachTask(task:data))
                }
                guard let initWatchTable = initWatchTable else {
                    return
                }
                initWatchTable(newTaskList)
            } catch {
                print("Deconding Error")
            }
        }
        #endif
    }
}
