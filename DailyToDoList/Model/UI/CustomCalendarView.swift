//
//  CustomCalendarView.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/17.
//

import Foundation
import UIKit
import FSCalendar


class CustomCalendarView : FSCalendar {
    override func awakeFromNib() {
        super.awakeFromNib()
        initCalendar()
    }
    
    func initCalendar() {
        //
        self.locale = Locale(identifier: "ko_KR")
        // 양옆 년도, 월 지우기
        self.appearance.headerMinimumDissolvedAlpha = 0.0
        //
        self.scrollEnabled = true
        self.scrollDirection = .vertical
        //
        self.calendarWeekdayView.weekdayLabels[0].text = "일"
        self.calendarWeekdayView.weekdayLabels[1].text = "월"
        self.calendarWeekdayView.weekdayLabels[2].text = "화"
        self.calendarWeekdayView.weekdayLabels[3].text = "수"
        self.calendarWeekdayView.weekdayLabels[4].text = "목"
        self.calendarWeekdayView.weekdayLabels[5].text = "금"
        self.calendarWeekdayView.weekdayLabels[6].text = "토"
        //
        self.appearance.weekdayTextColor = .black
        self.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 15.0)
        //
        self.headerHeight = 45
        self.appearance.headerTitleOffset = CGPoint(x: 0, y: -6)
        self.appearance.headerDateFormat = "YYYY년 MM월"
        self.appearance.headerTitleColor = .black
        self.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 18.0)
        self.appearance.headerTitleAlignment = .left
        //
        self.today = nil
        //
        self.appearance.titleWeekendColor = .red
        self.appearance.titleDefaultColor = .black
        //
        self.select(Date())
    }
}
