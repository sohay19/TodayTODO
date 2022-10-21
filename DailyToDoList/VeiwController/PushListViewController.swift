//
//  PushListViewController.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/21.
//

import Foundation
import UIKit


class PushListViewController : UIViewController {
    @IBOutlet weak var pushTable: UITableView!
    
    
    var pushList:[PushData] = []
    var requestList:[UNNotificationRequest] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.navigationItem.setHidesBackButton(true, animated: false)
        //
        pushTable.delegate = self
        pushTable.dataSource = self
        //
        initRefreshController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        self.loadPushData()
        DispatchQueue.main.async {
            SystemManager.shared.closeLoading()
        }
    }
}

extension PushListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pushList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let pushCell = tableView.dequeueReusableCell(withIdentifier: "PushCell", for: indexPath) as? PushCell else {
            return UITableViewCell()
        }
        let pushData = pushList[indexPath.row]
        pushCell.labelTitle.text = pushData.requestList.first!.content.title
        pushCell.labelAlarmTime.text = pushData.alarmTime
        //
        var repeatMsg = ""
        switch pushData.repeatType {
        case .EveryDay:
            repeatMsg = "매일 반복"
        case .Eachweek:
            repeatMsg = "매 주 "
            for request in pushData.requestList {
                guard let trigger = request.trigger as? UNCalendarNotificationTrigger else {
                    return UITableViewCell()
                }
                if let weekday = trigger.dateComponents.weekday {
                    repeatMsg += "\(Utils.getWeekDay(weekday-1)), "
                }
            }
            repeatMsg.removeLast()
            repeatMsg.removeLast()
            repeatMsg += "요일 반복"
        case .EachMonthOfOnce:
            repeatMsg = "매 월 "
            for request in pushData.requestList {
                guard let trigger = request.trigger as? UNCalendarNotificationTrigger else {
                    return UITableViewCell()
                }
                if let day = trigger.dateComponents.day {
                    repeatMsg += "\(day), "
                }
            }
            repeatMsg.removeLast()
            repeatMsg.removeLast()
            repeatMsg += "일 반복"
        case .EachMonthOfWeek:
            repeatMsg = "매 월 "
            var weekOfMonth = ""
            var weekDay = ""
            for request in pushData.requestList {
                guard let trigger = request.trigger as? UNCalendarNotificationTrigger else {
                    return UITableViewCell()
                }
                if let monthOfweek = trigger.dateComponents.weekOfMonth {
                    weekOfMonth += "\(monthOfweek)/ "
                }
                if let weekday = trigger.dateComponents.weekday {
                    weekDay += "\(Utils.getWeekDay(weekday-1))/ "
                }
            }
            if !weekOfMonth.isEmpty {
                weekOfMonth.removeLast()
                weekOfMonth.removeLast()
            }
            if !weekDay.isEmpty {
                weekDay.removeLast()
                weekDay.removeLast()
            }
            repeatMsg += "\(weekOfMonth)주, "
            repeatMsg += weekDay
            repeatMsg += "요일 반복"
        case .EachYear:
            repeatMsg = "매 년 "
            for request in pushData.requestList {
                guard let trigger = request.trigger as? UNCalendarNotificationTrigger else {
                    return UITableViewCell()
                }
                if let day = trigger.dateComponents.day {
                    repeatMsg += "\(day), "
                }
            }
            repeatMsg.removeLast()
            repeatMsg.removeLast()
            repeatMsg += "일 반복"
        default:
            //None
            repeatMsg = "반복 없음"
            
        }
        pushCell.labelRepeat.text = repeatMsg
        
        return pushCell
    }
}

//MARK: - Func
extension PushListViewController {
    func loadPushData() {
        SystemManager.shared.getAllPushRequest { requestList in
            var tmpDic:[String:[UNNotificationRequest]] = [:]
            for request in requestList {
                let id = request.content.userInfo[idKey] as! String
                if tmpDic[id] == nil {
                    tmpDic[id] = [request]
                } else {
                    tmpDic[id]?.append(request)
                }
            }
            //
            for item in tmpDic {
                let firstData = item.value.first!
                let repeatType = RepeatType(rawValue:firstData.content.userInfo[repeatTypeKey] as! String)!
                let alarmTime = firstData.content.userInfo[alarmTimeKey] as! String
                let endDate = firstData.content.userInfo[endDateKey] as! String
                //
                let data = PushData(id: item.key, repeatType: repeatType, alarmTime: alarmTime, endDate: endDate, requestList: item.value.sorted(by: {$0.identifier < $1.identifier}))
                self.pushList.append(data)
            }
        DispatchQueue.main.async {
                self.pushTable.reloadData()
            }
        }
    }
    //refresh controller 초기세팅
    func initRefreshController() {
        //
        let pushRefreshControl = UIRefreshControl()
        pushRefreshControl.addTarget(self, action: #selector(refreshPushView), for: .valueChanged)
        //초기화
        pushRefreshControl.endRefreshing()
        pushTable.refreshControl = pushRefreshControl
    }
    @objc func refreshPushView() {
        pushTable.refreshControl?.endRefreshing()
        pushTable.reloadData()
    }
}

//MARK: - Button Event
extension PushListViewController {
    @IBAction func clickSideMenu(_ sender:Any) {
        SystemManager.shared.openSideMenu(self)
    }
}
