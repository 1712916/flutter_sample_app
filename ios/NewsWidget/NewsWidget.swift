import SwiftUI
import WidgetKit

// Entry chứa thông tin từ App Group
struct NewsArticleEntry: TimelineEntry {
    let date: Date
    let url: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> NewsArticleEntry {
        NewsArticleEntry(date: Date(), url: "https://cdn2.thecatapi.com/images/21e.jpg")
    }

    func getSnapshot(in context: Context, completion: @escaping (NewsArticleEntry) -> ()) {
        let url: String

        if let userDefaults = UserDefaults(suiteName: "group.com.vinhnt.meow") {
            url = userDefaults.string(forKey: "app_url") ?? "❌ NOT FOUND"
        } else {
            url = "❌ Cannot load suite"
        }

        print("[WIDGET] 🔍 Snapshot URL: \(url)")
        let entry = NewsArticleEntry(date: Date(), url: url)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context) { entry in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct NewsWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 8) {
            Text("🕒 \(entry.date, style: .time)")
                .font(.caption)

            if let url = URL(string: entry.url), entry.url.starts(with: "http") {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                } placeholder: {
                    ProgressView()
                }
            } else {
                Text("❌ Invalid image URL")
                    .foregroundColor(.red)
                    .font(.caption2)
            }
        }
        .padding()
    }
}

struct NewsWidget: Widget {
    let kind: String = "NewsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
              NewsWidgetEntryView(entry: entry)
                              .background()
        }
        .configurationDisplayName("News Widget")
        .description("Displays an image from a shared app URL.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
