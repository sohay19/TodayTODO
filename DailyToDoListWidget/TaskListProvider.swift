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
        let entry = TaskListEntry(date: Date(), taskList: [EachTask()])
        completion(entry)
    }
    //실제 정보
    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskListEntry>) -> Void) {
        let currentDate = Date()
        //10분마다 refresh
        let refreshTimer = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)
        guard let refreshTimer = refreshTimer else {
            return
        }
        //데이터 가져오기
        let taskList = WidgetManager.shared.getTaskDataForDay(date: Date())
        if let taskList = taskList {
            //데이터 정리
            let entry = Entry(date: refreshTimer, taskList: taskList.map({$0}))
            let entries:[Entry] = [entry]
            let timeline = Timeline(entries: entries, policy: .after(refreshTimer))
            completion(timeline)
        } else {
            //데이터 정리
            let entry = Entry(date: refreshTimer, taskList: [EachTask()])
            let entries:[Entry] = [entry]
            let timeline = Timeline(entries: entries, policy: .after(refreshTimer))
            completion(timeline)
        }
    }
}

struct TaskListEntry: TimelineEntry {
    var date: Date
    var taskList: [EachTask]
}
