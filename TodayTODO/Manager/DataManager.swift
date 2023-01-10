//
//  DataManager.swift
//  dailytimetable
//
//  Created by 소하 on 2022/09/05.
//
// App


import Foundation
import FirebaseAuth
import UserNotifications
import RealmSwift
import Realm
import WidgetKit


class DataManager {
    static let shared = DataManager()
    private init() { }
    
    private let realmManager = RealmManager()
    private let pushManager = PushManager()
}

//MARK: - Func
extension DataManager {
    func setRealm() {
        realmManager.setRealm()
    }
    func initRealm() {
        realmManager.openRealm()
    }
    func deleteRealmFile() {
        realmManager.deleteOriginFile()
    }
    //
    func getRealmURL() -> URL? {
        return realmManager.getRealmURL()
    }
    func copyRealm() {
        let isUpadteA = UserDefaults.shared.bool(forKey: UpdateAKey)
        //워치 연동
        if !isUpadteA {
            //워치 기존데이터 모두 삭제
            WatchConnectManager.shared.sendToWatchAlarm(.Delete, [])
            WatchConnectManager.shared.sendToWatchTask(.Delete, [])
            WatchConnectManager.shared.sendToWatchCategory(.Delete, [])
            //워치에 데이터 재전달
            let orderList = DataManager.shared.getCategoryOrder()
            WatchConnectManager.shared.sendToWatchCategoryOrder(orderList)
            WatchConnectManager.shared.sendToWatchALL()
        }
    }
}

//MARK: - UserDefault
extension DataManager {
    func setFont(_ type:FontType) {
        UserDefaults.shared.set(type.rawValue, forKey: FontKey)
        switch type {
        case .Barunpen:
            K_Font_B = NanumBarunpen_B
            K_Font_R = NanumBarunpen_R
            K_FontSize = Barunpen_FontSize
        case .SquareRound:
            K_Font_B = NanumSquareRound_B
            K_Font_R = NanumSquareRound_R
            K_FontSize = SquareRound_FontSize
        case .GmarketSans:
            K_Font_B = GmarketSans_B
            K_Font_R = GmarketSans_R
            K_FontSize = GmarketSans_FontSize
        case .GangwonEduAll:
            K_Font_B = GangwonEduAll_B
            K_Font_R = GangwonEduAll_R
            K_FontSize = GangwonEduAll_FontSize
        }
    }
    
    func getFont() -> FontType {
        guard let type = UserDefaults.shared.string(forKey: FontKey) else {
            setFont(.Barunpen)
            return .Barunpen
        }
        guard let fontType = FontType(rawValue: type) else {
            return .Barunpen
        }
        return fontType
    }
    
    func setTheme(_ theme:String) {
        UserDefaults.shared.set(theme, forKey: ThemeKey)
        BackgroundImage = theme
    }
    
    func getTheme() -> String {
        guard let imgType = UserDefaults.shared.string(forKey: ThemeKey) else {
            setTheme(WhiteBackImage)
            return BackgroundImage
        }
        return imgType
    }
    
    func getWidgetTheme() -> String {
        guard let imgType = UserDefaults.shared.string(forKey: ThemeKey) else {
            return "WhiteWidgetBackImage"
        }
        switch imgType {
        case WhiteBackImage:
            return "WhiteWidgetBackImage"
        case BlackBackImage:
            return "BlackWidgetBackImage"
        case PaperBackImage:
            return "PaperWidgetBackImage"
        default:
            return "WhiteWidgetBackImage"
        }
    }
    
    func setPromotion(_ isOn:Bool) {
        UserDefaults.shared.set(isOn, forKey: PromotionKey)
    }
    
    func getPromotion() -> Bool {
        return UserDefaults.shared.bool(forKey: PromotionKey)
    }
    
    func setToday(_ today:String) {
        UserDefaults.shared.set(today, forKey: TodayKey)
    }
    
    func getToday() -> String {
        return UserDefaults.shared.string(forKey: TodayKey) ?? ""
    }
}


//MARK: - Task
extension DataManager {
    //ADD, Delete, Update
    func addTask(_ task:EachTask) {
        if let _ = realmManager.getTaskData(task.taskId) {
            updateTask(task)
        } else {
            realmManager.addTask(task)
            let option = task.optionData ?? OptionData()
            let isAlarm = option.isAlarm
            if isAlarm {
                addAlarmPush(task)
            }
#if os(iOS)
            WatchConnectManager.shared.sendToAppTask(.Add, [task])
#endif
        }
    }
    func updateTask(_ task:EachTask) {
        realmManager.updateTask(task)
        updateAlarmPush(task)
#if os(iOS)
        WatchConnectManager.shared.sendToAppTask(.Update, [task])
#endif
    }
    func deleteTask(_ taskId:String) {
        guard let task = realmManager.getTaskData(taskId) else { return }
        let option = task.optionData ?? OptionData()
        let isAlarm = option.isAlarm
        if isAlarm {
            deleteAlarmPush(task.taskId)
        }
        let deletedTask = task.clone()
        realmManager.deleteTask(task)
#if os(iOS)
        WatchConnectManager.shared.sendToAppTask(.Delete, [deletedTask])
#endif
    }
    func deleteTask(_ task:EachTask) {
        let option = task.optionData ?? OptionData()
        let isAlarm = option.isAlarm
        if isAlarm {
            deleteAlarmPush(task.taskId)
        }
        let deletedTask = task.clone()
        realmManager.deleteTask(task)
#if os(iOS)
        WatchConnectManager.shared.sendToAppTask(.Delete, [deletedTask])
#endif
    }
    func deleteAllTask() {
        realmManager.deleteAllTask()
#if os(iOS)
        WatchConnectManager.shared.sendToWatchTask(.Delete, [])
#endif
    }
    //load
    func getAllTask() -> [EachTask] {
        return realmManager.getTaskAllData()
    }
    func getTodayTask() -> [EachTask] {
        return realmManager.getTaskDataForDay(date: Date())
    }
    func getMonthTask(date:Date) -> [EachTask] {
        return realmManager.getTaskDataForMonth(date: date)
    }
    func getTask(_ taskId:String) -> EachTask? {
        return realmManager.getTaskData(taskId)
    }
    func getTaskCategory(category:String ) -> [EachTask] {
        return realmManager.getTaskForCategory(category)
    }
}

//MARK: - Cetegory
extension DataManager {
    //
    func addCategory(_ category:CategoryData) {
        if let _ = realmManager.getCategory(category.title) {
            updateCategory(category)
        } else {
            realmManager.addCategory(category)
        }
#if os(iOS)
            WatchConnectManager.shared.sendToWatchCategory(.Add, [category])
#endif
    }
    //
    func updateCategory(_ category:CategoryData) {
        guard let orderList = UserDefaults.shared.array(forKey: CategoryOrderKey) as? [String],
              let originCategory = realmManager.getCategory(category.primaryKey) else {
            return
        }
        var newOrder = orderList
        if let index = orderList.firstIndex(where: { $0 == originCategory.title }) {
            newOrder[index] = category.title
        }
        setCategoryOrder(newOrder)
        realmManager.updateCategory(category)
#if os(iOS)
        WatchConnectManager.shared.sendToWatchCategory(.Update, [category])
#endif
    }
    //load
    func getCategory(_ category:String) -> CategoryData? {
        return realmManager.getCategory(category)
    }
    func getAllCategory() -> [CategoryData] {
        return realmManager.loadCategory()
    }
    //
    func deleteCategory(_ category:String) {
        guard let category = realmManager.getCategory(category) else { return }
        let deletedCategory = category.clone()
        realmManager.deleteCategory(category)
        //
        var newList = DataManager.shared.getCategoryOrder()
        if let index = newList.firstIndex(of: deletedCategory.title) {
            newList.remove(at: index)
        }
        setCategoryOrder(newList)
#if os(iOS)
        WatchConnectManager.shared.sendToWatchCategory(.Delete, [deletedCategory])
#endif
    }
    func deleteCategory(_ category:CategoryData) {
        let deletedCategory = category.clone()
        realmManager.deleteCategory(category)
        //
        var newList = DataManager.shared.getCategoryOrder()
        if let index = newList.firstIndex(of: deletedCategory.title) {
            newList.remove(at: index)
        }
        setCategoryOrder(newList)
#if os(iOS)
        WatchConnectManager.shared.sendToWatchCategory(.Delete, [deletedCategory])
#endif
    }
    //
    func deleteAllCategory() {
        realmManager.deleteAllCategory()
        setCategoryOrder([String]())
#if os(iOS)
        WatchConnectManager.shared.sendToWatchCategory(.Delete, [])
#endif
    }
    /* ORDER */
    func reloadCategoryOrder() {
        let list = realmManager.getCategoryOrder()
        // 기존에 CategoryOrderData가 없었다면 UserDefults 사용
        if list.count == 0 {
            let newOrder = CategoryOrderData(order: getCategoryOrder())
            realmManager.setCategoryOrder(newOrder)
            return
        }
        setCategoryOrderUser(list)
    }
    func getCategoryOrder() -> [String] {
        guard let list = UserDefaults.shared.array(forKey: CategoryOrderKey) as? [String] else {
            return []
        }
        return list
    }
    func setCategoryOrder(_ list:[String]) {
        setCategoryOrderUser(list)
        setCategoryOrderRealm(list)
    }
    //set
    func setCategoryOrderUser(_ list:[String]) {
        UserDefaults.shared.set(list, forKey: CategoryOrderKey)
    }
    func setCategoryOrderRealm(_ list:[String]) {
        let categoryOrder = CategoryOrderData(order: list)
        realmManager.setCategoryOrder(categoryOrder)
#if os(iOS)
        WatchConnectManager.shared.sendToWatchCategoryOrder(list)
#endif
    }
    func getCategoryColor(_ category:String) -> UIColor {
        return realmManager.getCategoryColor(category)
    }
}

//MARK: - Push
extension DataManager {
    //전체 push load
    func getAllPush(_ complete: @escaping ([UNNotificationRequest]) -> Void) {
        pushManager.getAllRequest(complete)
    }
    //오늘자 push load
    func getTodayPush(_ complete: @escaping ([UNNotificationRequest]) -> Void) {
        pushManager.getAllRequest { list in
            let date = Utils.dateToDateString(Date())
            let requestList = list.filter { request in
                guard let trigger = request.trigger as? UNCalendarNotificationTrigger else {
                    return false
                }
                guard let next = trigger.nextTriggerDate() else {
                    return false
                }
                let nextDate = Utils.dateToDateString(next)
                if date == nextDate {
                    return true
                } else {
                    return false
                }
            }
            complete(requestList)
        }
    }
    // 뱃지 카운트 zero set
    func removeBadgeCnt() {
        pushManager.removeBadgeCnt()
    }
}

//MARK: - Push & Alarm
extension DataManager {
    //alarmInfo, push 모두 ADD
    func addAlarmPush(_ task:EachTask) {
        if let _ = realmManager.getAlarmInfo(task.taskId) {
            updateAlarmPush(task)
        } else {
            let option = task.optionData ?? OptionData()
            let alarmTime = option.alarmTime
            let idList = pushManager.addNotification(task)
            let alarmInfo = AlarmInfo(task.taskId, idList, alarmTime)
            realmManager.addAlarm(idList, alarmInfo)
#if os(iOS)
            WatchConnectManager.shared.sendToWatchAlarm(.Add, [alarmInfo])
#endif
        }
    }
    //alarmInfo, push 모두 UPDATE
    func updateAlarmPush(_ taskId:String, removeId:String) {
        //해당 푸쉬만 삭제
        pushManager.deletePush([removeId])
        //alarmInfo 업데이트
        realmManager.updateAlarm(taskId, removeId)
#if os(iOS)
        if let alarmInfo = realmManager.getAlarmInfo(taskId) {
            WatchConnectManager.shared.sendToWatchAlarm(.Update, [alarmInfo])
        }
#endif
    }
    func updateAlarmPush(_ task:EachTask) {
        let option = task.optionData ?? OptionData()
        let isAlarm = option.isAlarm
        //삭제
        deleteAlarmPush(task.taskId)
        //새로운 알람이 있다면 추가
        if isAlarm {
            addAlarmPush(task)
        }
    }
    //alarmInfo, push 선택 삭제
    func deleteAlarmPush(_ taskId:String, _ id:String) {
        //alarminfo 있을 때
        if let alarmInfo = realmManager.getAlarmInfo(taskId) {
            let deletedAlarmInfo = alarmInfo.clone()
            let idList = realmManager.getAlarmIdList(taskId)
            pushManager.deletePush(idList)
            realmManager.deleteAlarm(alarmInfo)
#if os(iOS)
            WatchConnectManager.shared.sendToWatchAlarm(.Delete, [deletedAlarmInfo])
#endif
        } else {
            //alarminfo가 없을 때
            pushManager.deletePush([id])
        }
    }
    func deleteAlarmPush(_ taskId:String) {
        //alarminfo 있을 때
        if let alarmInfo = realmManager.getAlarmInfo(taskId) {
            let deletedAlarmInfo = alarmInfo.clone()
            let idList = realmManager.getAlarmIdList(taskId)
            pushManager.deletePush(idList)
            realmManager.deleteAlarm(alarmInfo)
#if os(iOS)
            WatchConnectManager.shared.sendToWatchAlarm(.Delete, [deletedAlarmInfo])
#endif
        }
    }
    //alarmInfo, push 모두 삭제
    func deleteAllAlarmPush() {
        pushManager.deleteAllPush()
        // alarmInfo 모두 삭제
        realmManager.deleteAllAlarm()
#if os(iOS)
        WatchConnectManager.shared.sendToWatchAlarm(.Delete, [])
#endif
    }
}

//MARK: - Alarm
extension DataManager {
    func getAllAlarm() -> [AlarmInfo] {
        return realmManager.getAllAlarmInfo()
    }
#if os(watchOS)
    func addAlarm(_ alarmInfo:AlarmInfo) {
        if let _ = realmManager.getAlarmInfo(alarmInfo.taskId) {
            updateAlarm(alarmInfo)
        } else {
            realmManager.addAlarm(alarmInfo.getIdList(), alarmInfo)
        }
    }
    func updateAlarm(_ alarmInfo:AlarmInfo) {
        realmManager.updateAlarm(alarmInfo)
    }
    func deleteAlarm(_ taskId:String) {
        realmManager.deleteAlarm(taskId)
    }
    func deleteAllAlarm() {
        realmManager.deleteAllAlarm()
    }
#endif
}
