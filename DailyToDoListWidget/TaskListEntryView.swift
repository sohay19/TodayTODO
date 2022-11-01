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
                ForEach(0..<maxCount, id: \.self) { index in
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
        GeometryReader {
            geometry in
            if task.title.isEmpty {
                Text("TODO를 등록해주세요!")
                    .font(.system(size: family == .systemSmall ? 14 : 16, weight: .semibold))
                    .foregroundColor(Color.init(uiColor: UIColor.label))
                    .frame(width: geometry.size.width, alignment: .topLeading)
            } else {
                switch family {
                case .systemSmall:
                    VStack(alignment: .center) {
                        Text(task.title)
                            .font(.system(size: family == .systemSmall ? 14 : 16, weight: .semibold))
                            .foregroundColor(Color.init(uiColor: UIColor.label))
                            .frame(width: geometry.size.width, height: geometry.size.height * 1/3, alignment: .topLeading)
                        
                        Text(task.memo)
                            .font(.system(size: family == .systemSmall ? 10 : 15, weight: .regular))
                            .foregroundColor(Color.init(uiColor: UIColor.label))
                            .frame(width: geometry.size.width, height: geometry.size.height * 2/3, alignment: .topLeading)
                        
                    }.frame(width: geometry.size.width, height: family == .systemLarge ? geometry.size.height/3 : geometry.size.height , alignment: .center)
                case .systemMedium:
                    VStack(alignment: .center) {
                        HStack {
                            Text(task.title)
                                .font(.system(size: family == .systemSmall ? 14 : 16, weight: .semibold))
                                .foregroundColor(Color.init(uiColor: UIColor.label))
                                .frame(width: geometry.size.width * 3/4, alignment: .topLeading)
                            
                            Divider()
                            
                            Text(task.alarmTime.isEmpty ? "알람 없음" : task.alarmTime)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(Color.init(uiColor: UIColor.secondaryLabel))
                                .frame(width: geometry.size.width * 1/4 ,alignment: .topTrailing)
                            
                        }.frame(width: geometry.size.width, height: geometry.size.height * 1/3, alignment: .top)
                        
                        Text(task.memo)
                            .font(.system(size: family == .systemSmall ? 10 : 15, weight: .regular))
                            .foregroundColor(Color.init(uiColor: UIColor.label))
                            .frame(width: geometry.size.width, height: geometry.size.height * 2/3, alignment: .topLeading)
                        
                    }.frame(width: geometry.size.width, height: geometry.size.height , alignment: .center)
                default:
                    //large
                    VStack(alignment: .center) {
                        HStack {
                            Text(task.title)
                                .font(.system(size: family == .systemSmall ? 14 : 16, weight: .semibold))
                                .foregroundColor(Color.init(uiColor: UIColor.label))
                                .frame(width: geometry.size.width * 3/4, alignment: .topLeading)
                            
                            Divider()
                            
                            Text(task.alarmTime.isEmpty ? "알람 없음" : task.alarmTime)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(Color.init(uiColor: UIColor.secondaryLabel))
                                .frame(width: geometry.size.width * 1/4 ,alignment: .topTrailing)
                            
                        }.frame(width: geometry.size.width, height: geometry.size.height * 1/3 * 1/2, alignment: .top)
                            .padding()
                        
                        Text(task.memo)
                            .font(.system(size: family == .systemSmall ? 10 : 15, weight: .regular))
                            .foregroundColor(Color.init(uiColor: UIColor.label))
                            .frame(width: geometry.size.width, height: geometry.size.height * 1/3 * 1/2, alignment: .topLeading)
                        
                    }.frame(width: geometry.size.width, height: geometry.size.height * 1/3, alignment: .center)
                }
            }
        }
        .padding()
    }
}
