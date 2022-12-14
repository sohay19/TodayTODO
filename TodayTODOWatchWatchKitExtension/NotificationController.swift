//
//  NotificationController.swift
//  DailyToDoListWatch WatchKit Extension
//
//  Created by 소하 on 2022/10/24.
//

import WatchKit
import Foundation
import UserNotifications

class NotificationController: WKUserNotificationInterfaceController {
    @IBOutlet weak var labelTitle:WKInterfaceLabel!
    @IBOutlet weak var labelCategory:WKInterfaceLabel!
    @IBOutlet weak var labelMemo: WKInterfaceLabel!
    
    override init() {
        // Initialize variables here.
        super.init()
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

    override func didReceive(_ notification: UNNotification) {
        // This method is called when a notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        printNoti(notification.request.content)
    }
}

extension NotificationController {
    func printNoti(_ content: UNNotificationContent) {
        labelCategory.setText(content.categoryIdentifier)
        labelTitle.setText(content.title)
        labelMemo.setText(content.body)
    }
}
