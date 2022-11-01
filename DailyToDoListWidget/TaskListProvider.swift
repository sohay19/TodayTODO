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
        let entry = TaskListEntry(date: Date(), taskList: [EachTask(id: "task_Id", taskDay: "9999-12-31", category: "카테고리", title: "오늘의 TODO!", memo: "오늘의 할일은~?", repeatType: RepeatType.None.rawValue, weekDay: [false,false,false,false,false,false,false], weekOfMonth: 0, isEnd: false, taskEndDate: "", isAlarm: true, alarmTime: "09:30", isDone: false)
        , EachTask(id: "task_Id", taskDay: "9999-12-31", category: "카테고리", title: "두번째 TODO!", memo: "열심히", repeatType: RepeatType.None.rawValue, weekDay: [false,false,false,false,false,false,false], weekOfMonth: 0, isEnd: false, taskEndDate: "", isAlarm: true, alarmTime: "13:30", isDone: false)
        , EachTask(id: "task_Id", taskDay: "9999-12-31", category: "카테고리", title: "마지막 TODO!", memo: "달리자", repeatType: RepeatType.None.rawValue, weekDay: [false,false,false,false,false,false,false], weekOfMonth: 0, isEnd: false, taskEndDate: "", isAlarm: true, alarmTime: "16:30", isDone: false)])
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
        let taskList = RealmManager.shared.getTaskDataForDay(date:Date())
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
