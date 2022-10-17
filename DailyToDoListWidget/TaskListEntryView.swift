//
//  TaskListEntryView.swift
//  dailytimetable
//
//  Created by 소하 on 2022/09/27.
//


import SwiftUI
import WidgetKit


struct TaskListEntryView: View {
    let entry: TaskListEntry
    
    @Environment(\.widgetFamily) var family
    
    var maxCount:Int {
        switch family {
        case .systemLarge:
            return 3
        default:
            return 1
        }
    }
    
    @ViewBuilder
    var body: some View {
        VStack(alignment: .leading) {
            let taskList = entry.taskList
            if taskList.count == 0 {
                TaskListView(task: EachTask())
            } else {
                ForEach(0..<taskList.count, id: \.self) { index in
                    TaskListView(task: taskList[index])
                }
            }
        }
        .padding(.all)
    }
}

struct TaskListView: View {
    let task: EachTask
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if task.title.isEmpty {
            GeometryReader {
                geometry in
                VStack(alignment: .leading) {
                    Text("일정이 없습니다")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.init(uiColor: UIColor.label))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        } else {
            GeometryReader {
                geometry in
                VStack(alignment: .leading) {
                    Text(task.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.init(uiColor: UIColor.label))
                        .frame(width: geometry.size.width, alignment: .leading)
                    
                    Text(task.memo)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.init(uiColor: UIColor.label))
                }.frame(width: geometry.size.width, height: family == .systemLarge ? geometry.size.height/3 : geometry.size.height , alignment: .top)
            }
            .padding()
        }
    }
}
