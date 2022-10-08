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
            let taskList = getTaskList(entry.taskList)
            ForEach(0..<taskList.count, id: \.self) { index in
                TaskListView(task: taskList[index])
            }
        }
        .padding(.all)
    }
    
    func getTaskList(_ list:[EachTask]) -> [EachTask] {
        var result:[EachTask] = []
        let curTime = Utils.dateToTimeString(Date())
        for task in list {
//            if task.startTime < curTime && curTime < task.endTime {
//                result.append(task)
//                if result.count == maxCount {
//                    break
//                }
//            }
        }
        return result
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
                    
                    HStack {
                        Text(task.taskTime)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.init(uiColor: UIColor.secondaryLabel))
                    }
                    
                    Text(task.memo)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.init(uiColor: UIColor.label))
                }.frame(width: geometry.size.width, height: family == .systemLarge ? geometry.size.height/3 : geometry.size.height , alignment: .top)
            }
            .padding()
        }
    }
}
