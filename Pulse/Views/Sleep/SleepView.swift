import SwiftUI
import HealthKit

struct SleepView: View {
    @State private var sleepData: SleepData? = nil
    @State private var isLoading = true
    @State private var weekData: [DailySleep] = []

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Uyku verisi yükleniyor...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !HealthKitService.shared.isAvailable {
                    unavailableView
                } else {
                    sleepContent
                }
            }
            .navigationTitle("Uyku")
            .navigationBarTitleDisplayMode(.large)
            .task { await loadData() }
        }
    }

    // MARK: - Content
    private var sleepContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                lastNightCard
                if !weekData.isEmpty {
                    weeklyChartSection
                }
                tipsSection
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    // MARK: - Last Night Card
    private var lastNightCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dün Gece")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if let sleep = sleepData {
                        Text(sleep.formattedDuration)
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(sleepColor(hours: sleep.totalHours))
                    } else {
                        Text("Veri yok")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.indigo)
            }

            if let sleep = sleepData {
                HStack(spacing: 16) {
                    if let start = sleep.startDate {
                        sleepTimeChip(label: "Yattı", time: start, icon: "moon.fill")
                    }
                    if let end = sleep.endDate {
                        sleepTimeChip(label: "Kalktı", time: end, icon: "sun.max.fill")
                    }
                }

                // Kalite göstergesi
                HStack {
                    Text("Uyku Kalitesi")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(sleepQuality(hours: sleep.totalHours))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(sleepColor(hours: sleep.totalHours))
                }

                ProgressView(value: min(sleep.totalHours / 8.0, 1.0))
                    .tint(sleepColor(hours: sleep.totalHours))
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.top, 8)
    }

    // MARK: - Sleep Time Chip
    private func sleepTimeChip(label: String, time: Date, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(time, format: .dateTime.hour().minute())
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Weekly Chart
    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Son 7 Gece")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(weekData) { day in
                    VStack(spacing: 4) {
                        Text(String(format: "%.1f", day.hours))
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(sleepColor(hours: day.hours))
                            .frame(width: 32, height: max(barHeight(for: day.hours), 4))
                        Text(day.dayLabel)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            HStack(spacing: 16) {
                legendDot(color: .green, label: "7+ sa (İyi)")
                legendDot(color: .orange, label: "6-7 sa (Orta)")
                legendDot(color: .red, label: "< 6 sa (Az)")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
        }
    }

    // MARK: - Tips
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Uyku İpuçları")
                .font(.headline)

            ForEach(sleepTips, id: \.title) { tip in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: tip.icon)
                        .foregroundStyle(.indigo)
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tip.title).font(.subheadline).fontWeight(.medium)
                        Text(tip.description).font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Unavailable
    private var unavailableView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 56))
                .foregroundStyle(.indigo)
            Text("HealthKit Kullanılamıyor")
                .font(.title3).fontWeight(.semibold)
            Text("Bu cihazda Apple Health desteklenmiyor.")
                .font(.subheadline).foregroundStyle(.secondary)
            Spacer()
        }
    }

    // MARK: - Helpers
    private func loadData() async {
        isLoading = true
        await HealthKitService.shared.requestAuthorization()
        sleepData = await HealthKitService.shared.fetchLastNightSleep()
        weekData = await fetchWeekSleep()
        isLoading = false
    }

    private func fetchWeekSleep() async -> [DailySleep] {
        var result: [DailySleep] = []
        let calendar = Calendar.current
        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: .now) else { continue }
            let data = await HealthKitService.shared.fetchSleepForDate(date)
            let label = dayOffset == 0 ? "Bug." : calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
            result.append(DailySleep(date: date, hours: data?.totalHours ?? 0, dayLabel: label))
        }
        return result
    }

    private func barHeight(for hours: Double) -> CGFloat {
        let maxHeight: CGFloat = 100
        return CGFloat(hours / 10.0) * maxHeight
    }

    private func sleepColor(hours: Double) -> Color {
        if hours >= 7 { return .green }
        if hours >= 6 { return .orange }
        return hours == 0 ? .secondary : .red
    }

    private func sleepQuality(hours: Double) -> String {
        if hours >= 8 { return "Mükemmel" }
        if hours >= 7 { return "İyi" }
        if hours >= 6 { return "Orta" }
        return "Az"
    }

    let sleepTips: [(title: String, description: String, icon: String)] = [
        ("Düzenli uyku saati", "Her gün aynı saatte yat ve kalk.", "clock.fill"),
        ("Ekran ışığını azalt", "Yatmadan 1 saat önce telefon/TV kullanımını kısıt.", "moon.fill"),
        ("Karanlık ve serin oda", "Uyku kalitesi için oda sıcaklığı 18-20°C ideal.", "thermometer"),
        ("Kafein dikkat", "Öğleden sonra kafein tüketiminden kaçın.", "cup.and.saucer.fill")
    ]
}

struct DailySleep: Identifiable {
    let id = UUID()
    let date: Date
    let hours: Double
    let dayLabel: String
}
