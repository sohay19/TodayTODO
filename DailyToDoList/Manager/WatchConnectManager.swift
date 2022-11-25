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
    //워치로 Task 보내기
    func sendToWatchTask() {
        guard session.activationState == .activated || session.activationState == .inactive else {
            print("activationState is notActivated")
            return
        }
        do {
            //Category리스트 보내기
            let loadCategoryList = DataManager.shared.loadCategory()
            var categoryList:[NSCategoryData] = []
            for data in loadCategoryList {
                categoryList.append(NSCategoryData.init(category:data))
            }
            let categoryDataForWatch = try JSONEncoder().encode(NSCategoryDataList(categoryList: categoryList))
            session.transferUserInfo([
                sendTypeKey:SendType.Update.rawValue,
                dataTypeKey:DataType.NSCategoryDataList.rawValue,
                dataKey:categoryDataForWatch])
            //Task 보내기
            let founData = DataManager.shared.getTodayTask()
            var taskList:[NSEachTask] = []
            for data in founData {
                taskList.append(NSEachTask.init(task: data))
            }
            let taskDataForWatch = try JSONEncoder().encode(NSEachTaskList(taskList: taskList))
            session.transferUserInfo([
                sendTypeKey:SendType.Update.rawValue,
                dataTypeKey:DataType.NSEachTaskList.rawValue,
                dataKey:taskDataForWatch])
        } catch {
            print("sendToWatchTask Error")
        }
    }
    // 워치로 카테고리 추가 명령
    func sendToWatchAddCategory(_ categoryData:CategoryData) {
        guard session.activationState == .activated || session.activationState == .inactive else {
            print("activationState is notActivated")
            return
        }
        do {
            let dataForApp = try JSONEncoder().encode(NSCategoryData(category: categoryData))
            session.transferUserInfo([
                sendTypeKey:SendType.Add.rawValue,
                dataTypeKey:DataType.NSEachTask.rawValue,
                dataKey:dataForApp])
        } catch {
            print("Encoding Error")
        }
    }
    //워치로 Category 삭제 명령 보내기
    func sendToWatchCategoryDelete(_ categoryData:CategoryData?) {
        guard session.activationState == .activated || session.activationState == .inactive else {
            print("activationState is notActivated")
            return
        }
        do {
            if let categoryData = categoryData {
                let dataForApp = try JSONEncoder().encode(NSCategoryData(category: categoryData))
                session.transferUserInfo([
                    sendTypeKey:SendType.Delete.rawValue,
                    dataTypeKey:DataType.NSCategoryData.rawValue,
                    dataKey:dataForApp])
            } else {
                session.transferUserInfo([
                    sendTypeKey:SendType.Delete.rawValue,
                    dataTypeKey:DataType.NSCategoryDataList.rawValue])
            }
        } catch {
            print("Encoding Error")
        }
    }
    //
    func sendToAppTask(_ task:EachTask) {
        guard session.activationState == .activated || session.activationState == .inactive else {
            print("activationState is notActivated")
            return
        }
        do {
            let dataForApp = try JSONEncoder().encode(NSEachTask(task: task))
            session.transferUserInfo([
                sendTypeKey:SendType.Update.rawValue,
                dataTypeKey:DataType.NSEachTask.rawValue,
                dataKey:dataForApp])
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
        let dataType = userInfo[dataTypeKey] as! String
#if os(iOS)
        do {
            switch SendType(rawValue: userInfo[sendTypeKey] as! String) {
            case .Update:
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
            default:
                break
            }
        } catch {
            print("Deconding Error")
        }
#else
        do {
            switch SendType(rawValue: userInfo[sendTypeKey] as! String) {
            case .Add:
                switch DataType(rawValue: dataType) {
                case .NSEachTask:
                    break
                case .NSEachTaskList:
                    break
                case .NSCategoryData:
                    let receiveMsgData = try JSONDecoder().decode(NSCategoryData.self, from: userInfo[dataKey] as! Data)
                    let data = CategoryData(receiveMsgData.title, receiveMsgData.colorList)
                    DataManager.shared.addCategory(data)
                case .NSCategoryDataList:
                    break
                default:
                    break
                }
            case .Update:
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
            case .Delete:
                switch DataType(rawValue: dataType) {
                case .NSEachTask:
                    break
                case .NSEachTaskList:
                    break
                case .NSCategoryData:
                    DataManager.shared.deleteAllCategory()
                case .NSCategoryDataList:
                    let receiveMsgData = try JSONDecoder().decode(NSCategoryData.self, from: userInfo[dataKey] as! Data)
                    let data = CategoryData(receiveMsgData.title, receiveMsgData.colorList)
                    DataManager.shared.deleteCategory(data)
                default:
                    break
                }
            default:
                break
            }
        } catch {
            print("Deconding Error")
        }
#endif
    }
}
