//
//  TaskListProvider.swift
//  dailytimetable
//
//  Created by 소하 on 2022/09/27.
//

import WidgetKit
import SwiftUI
import Foundation


struct TaskListProvider: TimelineProvider {
    typealias Entry = TaskListEntry
    //특정내용 X
    func placeholder(in context: Context) -> TaskListEntry {
        TaskListEntry(date: Date(), taskList: [EachTask()])
    }
    //위젯 갤러리에서 보여질 부분
    func getSnapshot(in context: Context, completion: @escaping (TaskListEntry) -> Void) {
        let option1 = OptionData(taskId: "task_Id", weekDay: [false,false,false,false,false,false,false], weekOfMonth: 0, isEnd: false, taskEndDate: "", isAlarm: true, alarmTime: "09:30")
        let task1 = EachTask(id: "task_Id", taskDay: "9999-12-31", category: "카테고리", time: "09:30", title: "오늘의 TODO!", memo: "오늘의 할일은~?", repeatType: RepeatType.None.rawValue, optionData: option1, isDone: false)
        let option2 = OptionData(taskId: "task_Id", weekDay: [false,false,false,false,false,false,false], weekOfMonth: 0, isEnd: false, taskEndDate: "", isAlarm: true, alarmTime: "13:30")
        let task2 = EachTask(id: "task_Id", taskDay: "9999-12-31", category: "카테고리", time: "13:30", title: "두번째 TODO!", memo: "열심히", repeatType: RepeatType.None.rawValue, optionData: option2, isDone: false)
        let option3 = OptionData(taskId: "task_Id", weekDay: [false,false,false,false,false,false,false], weekOfMonth: 0, isEnd: false, taskEndDate: "", isAlarm: true, alarmTime: "16:30")
        let task3 = EachTask(id: "task_Id", taskDay: "9999-12-31", category: "카테고리", time: "16:30", title: "마지막 TODO!", memo: "달리자", repeatType: RepeatType.None.rawValue, optionData: option3, isDone: false)
        let entry = TaskListEntry(date: Date(), taskList: [task1, task2, task3])
        completion(entry)
    }
    //실제 정보
    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskListEntry>) -> Void) {
        let currentDate = Date()
        //1분마다 refresh
        let refreshTimer = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)
        guard let refreshTimer = refreshTimer else {
            return
        }
        //데이터 가져오기
        let orderList = DataManager.shared.getCategoryOrder()
        var taskList = DataManager.shared.getTodayTask()
        //isDone 제외
        taskList = taskList.reduce([EachTask]()) {
            return !$1.isDone ? $0 + [$1] : $0
        }
        //우선순위 정렬
        taskList.sort {
            if let first = orderList.firstIndex(of: $0.category), let second = orderList.firstIndex(of: $1.category) {
                if $0.isDone {
                    return false
                }
                if $1.isDone {
                    return true
                }
                return first < second
            }
            return false
        }
        let entry = Entry(date: refreshTimer, taskList: taskList)
        let entries:[Entry] = [entry]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct TaskListEntry: TimelineEntry {
    var date: Date
    var taskList: [EachTask]
}
