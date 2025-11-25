import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), balance: 1250000, exchangeRate: 1350.0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), balance: 1250000, exchangeRate: 1350.0)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // In a real app, fetch actual data from shared storage (App Group)
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, balance: 1250000, exchangeRate: 1350.0)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let balance: Double
    let exchangeRate: Double
}

struct AccountBookWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("나의 자산")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("₩\(Int(entry.balance))")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .minimumScaleFactor(0.5)
            
            Spacer()
            
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.green)
                Text("1 USD = ₩\(Int(entry.exchangeRate))")
                    .font(.caption2)
            }
            
            Text(entry.date, style: .time)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct AccountBookWidget: Widget {
    let kind: String = "AccountBookWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                AccountBookWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                AccountBookWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("가계부 위젯")
        .description("현재 잔액과 환율을 확인하세요.")
    }
}

#Preview(as: .systemSmall) {
    AccountBookWidget()
} timeline: {
    SimpleEntry(date: .now, balance: 1250000, exchangeRate: 1350.0)
}
