//
//  FlatlandWidget.swift
//  FlatlandWidget
//
//  Created by Stuart Rankin on 4/10/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider
{
    func placeholder(in context: Context) -> SimpleEntry
    {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ())
    {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ())
    {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry
{
    let date: Date
}

struct FlatlandWidgetEntryView : View
{
    var entry: Provider.Entry

    var body: some View
    {
//        Image("PlaceholderImage")
        Text(entry.date, style: .time)
    }
}

@main struct FlatlandWidget: Widget
{
    let kind: String = "FlatlandWidget"

    var body: some WidgetConfiguration
    {
        StaticConfiguration(kind: kind, provider: Provider())
        {
            entry in
            FlatlandWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Flatland View")
        .description("Flatland in a widget.")
    }
}

struct FlatlandWidget_Previews: PreviewProvider
{
    static var previews: some View
    {
        FlatlandWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
