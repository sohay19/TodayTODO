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
                TaskListView(list: [])
            } else {
                TaskListView(list: entry.taskList)
            }
        }
        .padding(.all)
    }
}

struct TaskListView: View {
    let list: [EachTask]
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        let K_Size:CGFloat = 14
        let N_Size:CGFloat = 12
        //
        GeometryReader { geometry in
            if list.count == 0 {
                VStack(alignment: .center) {
                    Text("TODO를 등록해주세요!")
                        .font(.custom(K_Font_B, size: K_Size))
                        .foregroundColor(.black)
                }
            } else {
                switch family {
                case .systemSmall:
                    let task = list.first!
                    VStack(spacing: 9) {
                        Text(task.title)
                            .font(.custom(K_Font_B, size: K_Size))
                            .foregroundColor(.black)
                            .truncationMode(.tail)
                        
                        Text(task.memo)
                            .font(.custom(K_Font_R, size: K_Size))
                            .foregroundColor(.black)
                            .truncationMode(.tail)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                case .systemMedium:
                    let task = list.first!
                    let taskTime = task.taskTime.isEmpty ? "--:--" : task.taskTime
                    VStack(spacing: 9) {
                        HStack {
                            Text(task.title)
                                .font(.custom(K_Font_B, size: K_Size))
                                .foregroundColor(Color.init(uiColor: UIColor.black))
                                .truncationMode(.tail)
                            
                            Spacer()
                            
                            Image(systemName: "alarm")
                                .foregroundColor(.gray)
                            
                            Text(taskTime)
                                .font(.custom(N_Font, size: N_Size))
                                .foregroundColor(.gray)
                                .truncationMode(.tail)
                        }.frame(width: geometry.size.width, alignment: .leading)
                        
                        HStack {
                            Text(task.memo)
                                .font(.custom(K_Font_R, size: K_Size))
                                .foregroundColor(.black)
                                .truncationMode(.tail)
                        }.frame(width: geometry.size.width, alignment: .leading)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                default:
                    VStack(spacing: 9) {
                        ForEach(list, id: \.self) { task in
                            let taskTime = task.taskTime.isEmpty ? "--:--" : task.taskTime
                            HStack {
                                Text(task.title)
                                    .font(.custom(K_Font_B, size: K_Size))
                                    .foregroundColor(.black)
                                    .truncationMode(.tail)
                                
                                Spacer()
                                
                                Image(systemName: "alarm")
                                    .foregroundColor(.gray)
                                
                                Text(taskTime)
                                    .font(.custom(N_Font, size: N_Size))
                                    .foregroundColor(.gray)
                                    .truncationMode(.tail)
                            }.frame(width: geometry.size.width, alignment: .leading)
                            
                            HStack {
                                Text(task.memo)
                                    .font(.custom(K_Font_R, size: K_Size))
                                    .foregroundColor(.black)
                                    .truncationMode(.tail)
                            }.frame(width: geometry.size.width, alignment: .leading)
                            
                            Spacer()
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                }
            }
        }
    }
}
