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
            TaskListView(taskList: entry.taskList)
        }
        .padding(EdgeInsets(top: 18, leading: 9, bottom: 18, trailing: 15))
    }
}

struct TaskListView: View {
    let taskList: [EachTask]
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        let K_Size:CGFloat = K_FontSize - 1
        let N_Size:CGFloat = 12
        //
        GeometryReader { geometry in
            if taskList.count == 0 {
                VStack(alignment: .center) {
                    Text("TODO를 등록해주세요!")
                        .font(.custom(K_Font_B, size: K_Size))
                        .foregroundColor(.black)
                }
            } else {
                switch family {
                case .systemSmall:
                    let task = taskList.first!
                    let color = DataManager.shared.getCategoryColor(task.category)
                    HStack (alignment: .top, spacing: 9) {
                        VStack {
                            //카테고리 라인
                        }
                        .frame(width: 3.0, height: geometry.size.height, alignment: .topLeading)
                        .background(Color(uiColor: color))
                        
                        VStack(alignment: .leading, spacing: 9) {
                            Text(task.title)
                                .font(.custom(K_Font_B, size: K_Size))
                                .foregroundColor(DataManager.shared.getTheme() == BlackBackImage ? .white : .black)
                                .truncationMode(.tail)
                            
                            Text(task.memo)
                                .font(.custom(K_Font_R, size: K_Size))
                                .foregroundColor(DataManager.shared.getTheme() == BlackBackImage ? .white : .black)
                                .truncationMode(.tail)
                        }
                        .frame(width: geometry.size.width - 12.0, height: geometry.size.height, alignment: .topLeading)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                case .systemMedium:
                    let task = taskList.first!
                    let taskTime = task.taskTime.isEmpty ? "--:--" : task.taskTime
                    let color = DataManager.shared.getCategoryColor(task.category)
                    HStack (alignment: .top, spacing: 9) {
                        VStack {
                            //카테고리 라인
                        }
                        .frame(width: 3.0, height: geometry.size.height, alignment: .topLeading)
                        .background(Color(uiColor: color))
                        
                        VStack(spacing: 9) {
                            HStack {
                                Text(task.title)
                                    .font(.custom(K_Font_B, size: K_Size))
                                    .foregroundColor(DataManager.shared.getTheme() == BlackBackImage ? .white : .black)
                                    .truncationMode(.tail)
                                
                                Spacer()
                                
                                Image(systemName: "alarm")
                                    .foregroundColor(.gray)
                                
                                Text(taskTime)
                                    .font(.custom(N_Font, size: N_Size))
                                    .foregroundColor(.gray)
                                    .truncationMode(.tail)
                            }.frame(width: geometry.size.width - 12.0, alignment: .leading)
                            
                            HStack {
                                Text(task.memo)
                                    .font(.custom(K_Font_R, size: K_Size))
                                    .foregroundColor(DataManager.shared.getTheme() == BlackBackImage ? .white : .black)
                                    .truncationMode(.tail)
                            }.frame(width: geometry.size.width - 12.0, alignment: .leading)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                default:
                    VStack(spacing: 6) {
                        ForEach(taskList, id: \.self) { task in
                            let taskTime = task.taskTime.isEmpty ? "--:--" : task.taskTime
                            let color = DataManager.shared.getCategoryColor(task.category)
                            HStack (alignment: .top, spacing: 9) {
                                VStack {
                                    //카테고리 라인
                                }
                                .frame(width: 3.0, height: geometry.size.height/3 - 12.0, alignment: .topLeading)
                                .background(Color(uiColor: color))
                                
                                VStack(spacing: 9) {
                                    HStack {
                                        Text(task.title)
                                            .font(.custom(K_Font_B, size: K_Size))
                                            .foregroundColor(DataManager.shared.getTheme() == BlackBackImage ? .white : .black)
                                            .truncationMode(.tail)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "alarm")
                                            .foregroundColor(.gray)
                                        
                                        Text(taskTime)
                                            .font(.custom(N_Font, size: N_Size))
                                            .foregroundColor(.gray)
                                            .truncationMode(.tail)
                                    }.frame(width: geometry.size.width - 12.0, alignment: .topLeading)
                                    
                                    HStack {
                                        Text(task.memo)
                                            .font(.custom(K_Font_R, size: K_Size))
                                            .foregroundColor(DataManager.shared.getTheme() == BlackBackImage ? .white : .black)
                                            .truncationMode(.tail)
                                    }.frame(width: geometry.size.width - 12.0, alignment: .topLeading)
                                }
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height/3, alignment: .topLeading)
                        }
                        
                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                }
            }
        }
    }
}
