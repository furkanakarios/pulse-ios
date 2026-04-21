import WidgetKit
import SwiftUI

private let appGroup = "group.com.furkanakarios.pulse"
private let wAccent: Color = Color(red: 1.0, green: 0.302, blue: 0.369)
private let wBg: Color = Color(red: 1.0, green: 0.972, blue: 0.974)
private let wRingBg: Color = Color(red: 1.0, green: 0.878, blue: 0.886)

// MARK: - Entry

struct PulseEntry: TimelineEntry {
    let date: Date
    let waterMl: Double
    let waterGoalMl: Double
    let completedHabits: Int
    let totalHabits: Int

    static let placeholder = PulseEntry(
        date: .now, waterMl: 1200, waterGoalMl: 2500,
        completedHabits: 2, totalHabits: 4
    )
}

// MARK: - Provider

struct PulseProvider: TimelineProvider {
    func placeholder(in context: Context) -> PulseEntry { .placeholder }

    func getSnapshot(in context: Context, completion: @escaping (PulseEntry) -> Void) {
        completion(context.isPreview ? .placeholder : readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PulseEntry>) -> Void) {
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        completion(Timeline(entries: [readEntry()], policy: .after(nextUpdate)))
    }

    private func readEntry() -> PulseEntry {
        let d = UserDefaults(suiteName: appGroup) ?? .standard
        return PulseEntry(
            date: .now,
            waterMl: d.double(forKey: "widget_waterMl"),
            waterGoalMl: max(d.double(forKey: "widget_waterGoalMl"), 2500),
            completedHabits: d.integer(forKey: "widget_completedHabits"),
            totalHabits: d.integer(forKey: "widget_totalHabits")
        )
    }
}

// MARK: - Entry View

struct PulseWidgetEntryView: View {
    var entry: PulseEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemMedium: MediumView(entry: entry)
        default:            SmallView(entry: entry)
        }
    }
}

// MARK: - Small Widget

private struct SmallView: View {
    let entry: PulseEntry
    private var progress: Double { min(entry.waterMl / max(entry.waterGoalMl, 1), 1.0) }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(wRingBg, lineWidth: 9)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(wAccent, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 1) {
                    Text("\(Int(entry.waterMl))")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundStyle(wAccent)
                    Text("ml")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 82, height: 82)

            Text("Su Hedefi")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .overlay(
            ContainerRelativeShape()
                .inset(by: 2)
                .stroke(wAccent, lineWidth: 8)
        )
        .containerBackground(wBg, for: .widget)
    }
}

// MARK: - Medium Widget

private struct MediumView: View {
    let entry: PulseEntry
    private var waterProgress: Double { min(entry.waterMl / max(entry.waterGoalMl, 1), 1.0) }

    var body: some View {
        HStack(spacing: 16) {
            // Water
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 5) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(wAccent)
                    Text("SU")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(wAccent)
                }

                ZStack {
                    Circle()
                        .stroke(wRingBg, lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: waterProgress)
                        .stroke(wAccent, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 0) {
                        Text("\(Int(entry.waterMl))")
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundStyle(wAccent)
                        Text("/ \(Int(entry.waterGoalMl))")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 72, height: 72)
            }
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(Color.black.opacity(0.07))
                .frame(width: 1)
                .padding(.vertical, 8)

            // Habits
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(wAccent)
                    Text("ALIŞKANLIKLAR")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(wAccent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(entry.completedHabits)/\(entry.totalHabits)")
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundStyle(entry.completedHabits == entry.totalHabits && entry.totalHabits > 0 ? wAccent : .primary)
                    Text("tamamlandı")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .overlay(
            ContainerRelativeShape()
                .inset(by: 2)
                .stroke(wAccent, lineWidth: 8)
        )
        .containerBackground(wBg, for: .widget)
    }
}

// MARK: - Widget

struct PulseWidget: Widget {
    let kind = "PulseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PulseProvider()) { entry in
            PulseWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Pulse")
        .description("Günlük su ve alışkanlık takibi.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Bundle

@main
struct PulseWidgetBundle: WidgetBundle {
    var body: some Widget {
        PulseWidget()
    }
}
