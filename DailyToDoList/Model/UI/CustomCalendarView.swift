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
        self.backgroundColor = .clear
        //
        self.locale = Locale(identifier: "ko_KR")
        // 양옆 년도, 월 지우기
        self.appearance.headerMinimumDissolvedAlpha = 0.0
        //
        self.placeholderType = .none
        self.headerHeight = 0
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
        self.appearance.weekdayTextColor = .darkGray
        self.appearance.weekdayFont = UIFont(name: CalendalFont, size: CalendalFontSize - 5.0)
        //
        self.today = Date()
        self.appearance.todayColor = .clear
        self.appearance.titleTodayColor = .systemIndigo
        self.appearance.selectionColor = .defaultPink
        //
        self.appearance.titleWeekendColor = .defaultPink
        self.appearance.titleDefaultColor = .label
        self.appearance.titleFont = UIFont(name: CalendalFont, size: CalendalFontSize - 6.0)
        //
        self.select(Date())
    }
}
