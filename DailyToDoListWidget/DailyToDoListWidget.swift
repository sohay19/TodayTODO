//
//  DailyToDoListWidget.swift
//  DailyToDoListWidget
//
//  Created by 소하 on 2022/10/08.
//

import WidgetKit
import SwiftUI
import Intents


@main
struct WidgetList: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        TaskListWidget()
    }
}

struct TaskListWidget: Widget {
    static let kind: String = "TaskListWidget"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: TaskListWidget.kind,
                            provider: TaskListProvider()) { entry in
            TaskListEntryView(entry: entry)
                .unredacted()
        }
        .configurationDisplayName("Daily TODO")
        .description("오늘의 TODO를 볼 수 있습니다.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
