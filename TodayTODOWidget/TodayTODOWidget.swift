//
//  TodayTODOWidget.swift
//  TodayTODOWidget
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
                .background(Image(DataManager.shared.getTheme() == WhiteBackImage ? "WhiteWatchBackImage" : "BlackWatchBackImage")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity))
                .unredacted()
        }
        .configurationDisplayName("오늘의 투두")
        .description("오늘의 TODO를 볼 수 있습니다.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
