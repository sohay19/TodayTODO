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
    var session:WCSession
    //
    var reloadMainView:(()->Void)?
    
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
    //App -> Watch, Task
    func sendToWatchTask(_ type:SendType, _ task:EachTask) {
        guard session.activationState == .activated || session.activationState == .inactive else {
            print("activationState is notActivated")
            return
        }
        do {
            let newTask = NSEachTask.init(task: task)
            let taskDataForWatch = try JSONEncoder().encode(newTask)
            session.transferUserInfo([
                sendTypeKey:type,
                dataTypeKey:DataType.NSEachTask.rawValue,
                dataKey:taskDataForWatch])
        } catch {
            print("sendToWatchTask Error")
        }
    }
    //App -> Watch, 카테고리
    func sendToWatchCategory(_ type:SendType, _ categoryData:CategoryData) {
        guard session.activationState == .activated || session.activationState == .inactive else {
            print("activationState is notActivated")
            return
        }
        do {
            let dataForApp = try JSONEncoder().encode(NSCategoryData(category: categoryData))
            session.transferUserInfo([
                sendTypeKey:type,
                dataTypeKey:DataType.NSEachTask.rawValue,
                dataKey:dataForApp])
        } catch {
            print("Encoding Error")
        }
    }
    //App -> Watch, 카테고리 순서
    func sendToWatchCategoryOrder() {
        guard session.activationState == .activated || session.activationState == .inactive else {
            print("activationState is notActivated")
            return
        }
        do {
            //Category Order 보내기
            let orderList = DataManager.shared.getCategoryOrder()
            let orderData = try JSONEncoder().encode(orderList)
            session.transferUserInfo([
                sendTypeKey:SendType.Update.rawValue,
                dataTypeKey:DataType.Array.rawValue,
                dataKey:orderData])
        } catch {
            print("sendToWatchCategoryOrder Error")
        }
    }
    //App -> Watch, 카테고리
    func sendToWatchCategoryDelete(_ type:SendType, _ categoryData:CategoryData?) {
        guard session.activationState == .activated || session.activationState == .inactive else {
            print("activationState is notActivated")
            return
        }
        do {
            if let categoryData = categoryData {
                let dataForApp = try JSONEncoder().encode(NSCategoryData(category: categoryData))
                session.transferUserInfo([
                    sendTypeKey:type,
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
    //Watch -> App, Task 업데이트
    func sendToAppTask(_ type:SendType, _ task:EachTask) {
        guard session.activationState == .activated || session.activationState == .inactive else {
            print("activationState is notActivated")
            return
        }
        do {
            let dataForApp = try JSONEncoder().encode(NSEachTask(task: task))
            session.transferUserInfo([
                sendTypeKey:type,
                dataTypeKey:DataType.NSEachTask.rawValue,
                dataKey:dataForApp])
        } catch {
            print("Encoding Error")
        }
    }
}


//MARK: - WCSessionDelegate
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
            case .Add:
                break
            case .Update:
                switch DataType(rawValue: dataType) {
                case .NSEachTask:
                    let receiveMsgData = try JSONDecoder().decode(NSEachTask.self, from: userInfo[dataKey] as! Data)
                    let task = EachTask(task:receiveMsgData)
                    DataManager.shared.updateTask(task)
                    guard let reloadMainView = reloadMainView else {
                        return
                    }
                    DispatchQueue.main.async {
                        reloadMainView()
                    }
                case .NSEachTaskList:
                    break
                case .NSCategoryData:
                    break
                case .NSCategoryDataList:
                    break
                default:
                    break
                }
            case .Delete:
                break
            default:
                break
            }
        } catch {
            print("Deconding Error")
        }
#else
        do {
            switch DataType(rawValue: dataType) {
            case .NSEachTask:
                var newTaskList:[EachTask] = []
                let receiveMsgData = try JSONDecoder().decode(NSEachTask.self, from: userInfo[dataKey] as! Data)
                let task = EachTask(task:receiveMsgData)
                switch SendType(rawValue: userInfo[sendTypeKey] as! String) {
                case .Add:
                    DataManager.shared.addTask(task)
                case .Update:
                    DataManager.shared.updateTask(task)
                case .Delete:
                    DataManager.shared.deleteTask(task)
                }
            case .NSEachTaskList:
                var newTaskList:[EachTask] = []
                let receiveMsgData = try JSONDecoder().decode(NSEachTaskList.self, from: userInfo[dataKey] as! Data)
                switch SendType(rawValue: userInfo[sendTypeKey] as! String) {
                case .Add:
                    for data in receiveMsgData.taskList {
                        let task = EachTask(task:data)
                        DataManager.shared.addTask(task)
                    }
                case .Update:
                    for data in receiveMsgData.taskList {
                        let task = EachTask(task:data)
                        DataManager.shared.updateTask(task)
                    }
                case .Delete:
                    for data in receiveMsgData.taskList {
                        DataManager.shared.deleteTask(task)
                    }
                }
            case .NSCategoryData:
                let receiveMsgData = try JSONDecoder().decode(NSCategoryData.self, from: userInfo[dataKey] as! Data)
                let category = CategoryData(receiveMsgData.title, receiveMsgData.colorList)
                switch SendType(rawValue: userInfo[sendTypeKey] as! String) {
                case .Add:
                    DataManager.shared.addCategory(category)
                case .Update:
                    break
                case .Delete:
                    DataManager.shared.deleteCategory(category)
                }
            case .NSCategoryDataList:
                let receiveMsgData = try JSONDecoder().decode(NSCategoryDataList.self, from: userInfo[dataKey] as! Data)
                let loadList = DataManager.shared.loadCategory()
                switch SendType(rawValue: userInfo[sendTypeKey] as! String) {
                case .Add:
                    for data in receiveMsgData.categoryList {
                        let found = loadList.first(where: {$0.title == data.title})
                        if found == nil {
                            let category = CategoryData(data.title, data.colorList)
                            DataManager.shared.addCategory(category)
                        }
                    }
                case .Update:
                    break
                case .Delete:
                    DataManager.shared.deleteAllCategory()
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
