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
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
#else
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
            //Category 보내기
            let loadCategoryList = DataManager.shared.loadCategory()
            var categoryList:[NSCategoryData] = []
            for data in loadCategoryList {
                categoryList.append(NSCategoryData.init(category:data))
            }
            let categoryDataForWatch = try JSONEncoder().encode(NSCategoryDataList(categoryList: categoryList))
            session.transferUserInfo([ sendTypeKey:SendType.Update.rawValue, dataTypeKey:DataType.NSCategoryDataList.rawValue, dataKey:categoryDataForWatch])
            //Task 보내기
            let founData = DataManager.shared.getTodayTask()
            var taskList:[NSEachTask] = []
            for data in founData {
                taskList.append(NSEachTask.init(task: data))
            }
            let taskDataForWatch = try JSONEncoder().encode(NSEachTaskList(taskList: taskList))
            session.transferUserInfo([ sendTypeKey:SendType.Update.rawValue, dataTypeKey:DataType.NSEachTaskList.rawValue, dataKey:taskDataForWatch])
        } catch {
            print("sendToWatchTask Error")
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
            session.transferUserInfo([sendTypeKey:SendType.Update.rawValue, dataTypeKey:DataType.NSEachTask.rawValue, dataKey:dataForApp])
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
        switch SendType(rawValue: userInfo[sendTypeKey] as! String) {
        case .Update:
            do {
                let dataType = userInfo[dataTypeKey] as! String
                switch DataType(rawValue: dataType) {
                case .NSEachTask:
                    let receiveMsgData = try JSONDecoder().decode(NSEachTask.self, from: userInfo[dataKey] as! Data)
                    let task = EachTask(task:receiveMsgData)
                    DataManager.shared.updateTask(task)
                case .NSEachTaskList:
                    break
                case .NSCategoryData:
                    break
                case .NSCategoryDataList:
                    break
                default:
                    break
                }
            } catch {
                print("Deconding Error")
            }
        default:
            break
        }
#else
        switch SendType(rawValue: userInfo[sendTypeKey] as! String) {
        case .Update:
            do {
                let dataType = userInfo[dataTypeKey] as! String
                switch DataType(rawValue: dataType) {
                case .NSEachTask:
                    var newTaskList:[EachTask] = []
                    let receiveMsgData = try JSONDecoder().decode(NSEachTask.self, from: userInfo[dataKey] as! Data)
                    newTaskList.append(EachTask(task:receiveMsgData))
                    guard let initWatchTable = initWatchTable else {
                        return
                    }
                    initWatchTable(newTaskList)
                case .NSEachTaskList:
                    var newTaskList:[EachTask] = []
                    let receiveMsgData = try JSONDecoder().decode(NSEachTaskList.self, from: userInfo[dataKey] as! Data)
                    for data in receiveMsgData.taskList {
                        newTaskList.append(EachTask(task:data))
                    }
                    guard let initWatchTable = initWatchTable else {
                        return
                    }
                    initWatchTable(newTaskList)
                case .NSCategoryData:
                    break
                case .NSCategoryDataList:
                    let receiveMsgData = try JSONDecoder().decode(NSCategoryDataList.self, from: userInfo[dataKey] as! Data)
                    let loadList = DataManager.shared.loadCategory()
                    for data in receiveMsgData.categoryList {
                        let found = loadList.first(where: {$0.title == data.title})
                        if found == nil {
                            DataManager.shared.addCategory(CategoryData(data.title, data.colorList))
                        }
                    }
                default:
                    break
                }
            } catch {
                print("Deconding Error")
            }
            break
        default:
            break
        }
#endif
    }
}
