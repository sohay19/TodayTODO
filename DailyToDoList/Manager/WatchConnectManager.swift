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
    func sendToWatchTask() {
        guard session.activationState == .activated || session.activationState == .inactive else {
            print("activationState is notActivated")
            return
        }
        do {
            let founData = RealmManager.shared.getTaskDataForDay(date: Date())
            var taskList:[NSEachTask] = []
            for data in founData {
                taskList.append(NSEachTask.init(task: data))
            }
            let dataForWatch = try JSONEncoder().encode(NSEachTaskList(taskList: taskList))
            session.transferUserInfo([ sendTypeKey:SendType.Send.rawValue, dataTypeKey:DataType.NSEachTaskList.rawValue, taskDataKey:dataForWatch])
        } catch {
            print("getTaskDataForDay Error")
        }
    }
    //
    func sendAppToTask(_ task:EachTask) {
        guard session.activationState == .activated || session.activationState == .inactive else {
            print("activationState is notActivated")
            return
        }
        //
        do {
            let dataForApp = try JSONEncoder().encode(NSEachTask(task: task))
            session.transferUserInfo([sendTypeKey:SendType.Update.rawValue, dataTypeKey:DataType.NSEachTask.rawValue, taskDataKey:dataForApp])
        } catch {
            print("Encoding Error")
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
        switch SendType(rawValue: userInfo[sendTypeKey] as! String) {
        case .Send:
            break
        default:
            do {
                let dataType = userInfo[dataTypeKey] as! String
                switch DataType(rawValue: dataType) {
                case .NSEachTask:
                    let receiveMsgData = try JSONDecoder().decode(NSEachTask.self, from: userInfo[taskDataKey] as! Data)
                    let task = EachTask(task:receiveMsgData)
                    RealmManager.shared.updateTaskDataInWatch(task)
                case .NSEachTaskList:
                    break
                default:
                    break
                }
            } catch {
                print("Deconding Error")
            }
        }
#else
        print("didReceiveUserInfo_watchOS")
        switch SendType(rawValue: userInfo[sendTypeKey] as! String) {
        case .Send:
            do {
                let dataType = userInfo[dataTypeKey] as! String
                var newTaskList:[EachTask] = []
                switch DataType(rawValue: dataType) {
                case .NSEachTask:
                    let receiveMsgData = try JSONDecoder().decode(NSEachTask.self, from: userInfo[taskDataKey] as! Data)
                    newTaskList.append(EachTask(task:receiveMsgData))
                case .NSEachTaskList:
                    let receiveMsgData = try JSONDecoder().decode(NSEachTaskList.self, from: userInfo[taskDataKey] as! Data)
                    for data in receiveMsgData.taskList {
                        newTaskList.append(EachTask(task:data))
                    }
                default:
                    break
                }
                guard let initWatchTable = initWatchTable else {
                    return
                }
                initWatchTable(newTaskList)
            } catch {
                print("Deconding Error")
            }
        default:
            break
        }
#endif
    }
}
