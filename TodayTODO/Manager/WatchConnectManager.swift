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
    var reloadWatchView:(()->Void)?
    
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
    func sendToWatchTask(_ type:SendType, _ taskData:[EachTask]) {
        guard session.activationState == .activated || session.activationState == .inactive else {
            print("activationState is notActivated")
            return
        }
        do {
            if taskData.count > 0 {
                var list = [NSEachTask]()
                for task in taskData {
                    list.append(NSEachTask(task: task))
                }
                let dataForApp = try JSONEncoder().encode(NSEachTaskList(taskList: list))
                session.transferUserInfo([
                    sendTypeKey:type.rawValue,
                    dataTypeKey:DataType.NSEachTaskList.rawValue,
                    dataKey:dataForApp])
                print(type.rawValue)
            } else {
                session.transferUserInfo([
                    sendTypeKey:SendType.Delete.rawValue,
                    dataTypeKey:DataType.NSEachTaskList.rawValue])
            }
        } catch {
            print("Encoding Error")
        }
    }
    //App -> Watch, 카테고리
    func sendToWatchCategory(_ type:SendType, _ categoryList:[CategoryData]) {
        guard session.activationState == .activated || session.activationState == .inactive else {
            print("activationState is notActivated")
            return
        }
        do {
            if categoryList.count > 0 {
                var list = [NSCategoryData]()
                for category in categoryList {
                    list.append(NSCategoryData(category: category))
                }
                let dataForApp = try JSONEncoder().encode(NSCategoryDataList(categoryList: list))
                session.transferUserInfo([
                    sendTypeKey:type.rawValue,
                    dataTypeKey:DataType.NSCategoryDataList.rawValue,
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
    //App -> Watch, 알람
    func sendToWatchAlarm(_ type:SendType, _ alarmData:[AlarmInfo]) {
        guard session.activationState == .activated || session.activationState == .inactive else {
            print("activationState is notActivated")
            return
        }
        do {
            if alarmData.count > 0 {
                var list = [NSAlarmInfo]()
                for alarm in alarmData {
                    list.append(NSAlarmInfo(alarmInfo: alarm))
                }
                let dataForApp = try JSONEncoder().encode(NSAlarmInfoList(alarmList: list))
                session.transferUserInfo([
                    sendTypeKey:type.rawValue,
                    dataTypeKey:DataType.NSAlarmInfoList.rawValue,
                    dataKey:dataForApp])
            } else {
                session.transferUserInfo([
                    sendTypeKey:SendType.Delete.rawValue,
                    dataTypeKey:DataType.NSAlarmInfoList.rawValue])
            }
        } catch {
            print("Encoding Error")
        }
    }
    //App -> Watch, 카테고리 순서
    func sendToWatchCategoryOrder(_ orderList:[String]) {
        guard session.activationState == .activated || session.activationState == .inactive else {
            print("activationState is notActivated")
            return
        }
        do {
            let orderData = try JSONEncoder().encode(orderList)
            session.transferUserInfo([
                sendTypeKey:SendType.Update.rawValue,
                dataTypeKey:DataType.Array.rawValue,
                dataKey:orderData])
        } catch {
            print("sendToWatchCategoryOrder Error")
        }
    }
    //App -> Watch, All Data
    func sendToWatchALL() {
        guard session.activationState == .activated || session.activationState == .inactive else {
            print("activationState is notActivated")
            return
        }
        //Task
        let taskList = DataManager.shared.getAllTask()
        if taskList.count > 0 {
            sendToWatchTask(.Update, taskList)
        }
        //Category
        let categoryList = DataManager.shared.getAllCategory()
        if categoryList.count > 0 {
            sendToWatchCategory(.Update, categoryList)
        }
        //Alarm
        let alarmList = DataManager.shared.getAllAlarm()
        if alarmList.count > 0 {
            sendToWatchAlarm(.Update, alarmList)
        }
        //
        UserDefaults.shared.set(true, forKey: UpdateAKey)
    }
    //Watch -> App, Task 업데이트
    func sendToAppTask(_ type:SendType, _ taskData:[EachTask]) {
        guard session.activationState == .activated || session.activationState == .inactive else {
            print("activationState is notActivated")
            return
        }
        do {
            var list = [NSEachTask]()
            for task in taskData {
                list.append(NSEachTask(task: task))
            }
            let dataForApp = try JSONEncoder().encode(NSEachTaskList(taskList: list))
            session.transferUserInfo([
                sendTypeKey:type.rawValue,
                dataTypeKey:DataType.NSEachTaskList.rawValue,
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
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        let dataType = userInfo[dataTypeKey] as! String
        let sendType = userInfo[sendTypeKey] as! String
        let isKey = userInfo.keys.contains(where: {$0 == dataKey})
#if os(iOS)
        do {
            switch DataType(rawValue: dataType) {
            case .NSEachTaskList:
                switch SendType(rawValue: sendType) {
                case .Update:
                    let receiveMsgData = try JSONDecoder().decode(NSEachTaskList.self, from: userInfo[dataKey] as! Data)
                    for data in receiveMsgData.taskList {
                        let task = EachTask(task:data)
                        DataManager.shared.updateTask(task)
                    }
                default:
                    break
                }
            default:
                break
            }
            //
            guard let reloadMainView = reloadMainView else {
                return
            }
            DispatchQueue.main.async {
                reloadMainView()
            }
        } catch {
            print("Deconding Error")
        }
#else
        DispatchQueue.main.async { [self] in
            do {
                switch DataType(rawValue: dataType) {
                case .Array:
                    let receiveMsgData = try JSONDecoder().decode(Array<String>.self, from: userInfo[dataKey] as! Data)
                    switch SendType(rawValue: sendType) {
                    case .Update:
                        var list = [String]()
                        for data in receiveMsgData {
                            list.append(data)
                        }
                        DataManager.shared.setCategoryOrderRealm(list)
                    default:
                        break
                    }
                case .NSEachTaskList:
                    if isKey {
                        let receiveMsgData = try JSONDecoder().decode(NSEachTaskList.self, from: userInfo[dataKey] as! Data)
                        switch SendType(rawValue: sendType) {
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
                                DataManager.shared.deleteTask(data.taskId)
                            }
                        default:
                            break
                        }
                    } else {
                        DataManager.shared.deleteAllTask()
                    }
                case .NSAlarmInfoList:
                    if isKey {
                        let receiveMsgData = try JSONDecoder().decode(NSAlarmInfoList.self, from: userInfo[dataKey] as! Data)
                        switch SendType(rawValue: sendType) {
                        case .Add:
                            for data in receiveMsgData.alarmList {
                                let alarmInfo = AlarmInfo(data)
                                DataManager.shared.addAlarm(alarmInfo)
                            }
                        case .Update:
                            for data in receiveMsgData.alarmList {
                                let alarmInfo = AlarmInfo(data)
                                DataManager.shared.updateAlarm(alarmInfo)
                            }
                        case .Delete:
                            for data in receiveMsgData.alarmList {
                                DataManager.shared.deleteAlarm(data.taskId)
                            }
                        default:
                            break
                        }
                    } else {
                        DataManager.shared.deleteAllAlarm()
                    }
                case .NSCategoryDataList:
                    if isKey {
                        let receiveMsgData = try JSONDecoder().decode(NSCategoryDataList.self, from: userInfo[dataKey] as! Data)
                        switch SendType(rawValue: sendType) {
                        case .Add:
                            for data in receiveMsgData.categoryList {
                                let category = CategoryData(data.title, data.colorList)
                                DataManager.shared.addCategory(category)
                            }
                        case .Update:
                            break
                        case .Delete:
                            for data in receiveMsgData.categoryList {
                                DataManager.shared.deleteCategory(data.title)
                            }
                        default:
                            break
                        }
                    } else {
                        DataManager.shared.deleteAllCategory()
                    }
                default:
                    break
                }
                //
                guard let reloadWatchView = reloadWatchView else {
                    return
                }
                DispatchQueue.main.async {
                    reloadWatchView()
                }
            } catch {
                print("Deconding Error")
            }
        }
#endif
    }
}
