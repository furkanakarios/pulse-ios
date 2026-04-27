//
//  WaterView.swift
//  Pulse — V2 Glass redesign (drop-in replacement)
//

import SwiftUI
import SwiftData

struct WaterView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("dailyWaterGoal") private var dailyWaterGoal: Double = 2500

    // BIND: real SwiftData query filtered to today, sorted by date ascending
    @Query(sort: \WaterEntry.date, order: .forward)
    private var allEntries: [WaterEntry]

    @State private var showCustomEntry = false
    @State private var customAmount: String = ""
    @State private var entryToDelete: WaterEntry? = nil

    private var todaysEntries: [WaterEntry] {
        allEntries.filter { Calendar.current.isDateInToday($0.date) }
    }

    private let presets: [(ml: Int, kind: ContainerKind, label: String)] = [
        (200, .glass,  "Bardak"),
        (250, .cup,    "Fincan"),
        (350, .mug,    "Kupa"),
        (500, .bottle, "Şişe"),
    ]

    private var amount: Int { todaysEntries.reduce(0) { $0 + $1.amountML } }
    private var pct: Double { dailyWaterGoal > 0 ? min(1.0, Double(amount) / dailyWaterGoal) : 0 }
    private var remainingML: Int { max(0, Int(dailyWaterGoal) - amount) }
    private var entriesByHour: [Int: Int] {
        Dictionary(grouping: todaysEntries, by: { $0.hour })
            .mapValues { $0.reduce(0) { $0 + $1.amountML } }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                hero
                    .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 18)

                hourlyCard
                    .padding(.horizontal, 20).padding(.bottom, 18)

                quickAddSection
                    .padding(.horizontal, 20).padding(.bottom, 18)

                lastEntriesSection
                    .padding(.horizontal, 20).padding(.bottom, 24)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color.pulseBgPage.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                PulseNavBrand()
            }
        }
        .sheet(isPresented: $showCustomEntry) {
            customEntrySheet
        }
        .alert("Kaydı sil", isPresented: Binding(
            get: { entryToDelete != nil },
            set: { if !$0 { entryToDelete = nil } }
        )) {
            Button("Sil", role: .destructive) {
                if let e = entryToDelete { modelContext.delete(e) }
                entryToDelete = nil
            }
            Button("İptal", role: .cancel) { entryToDelete = nil }
        } message: {
            if let e = entryToDelete {
                Text("\(e.amountML) ml kaydı silinecek.")
            }
        }
    }

    // MARK: - Hero card (bottle + summary)
    private var hero: some View {
        HStack(alignment: .top, spacing: 18) {
            BottleProgress(pct: pct)

            VStack(alignment: .leading, spacing: 0) {
                Text("BUGÜN")
                    .font(PulseType.eyebrow).tracking(1)
                    .foregroundStyle(Color.pulseWater)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", Double(amount)/1000.0))
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .tracking(-1.4)
                        .foregroundStyle(Color.pulseWaterDeep)
                    Text("L")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.pulseTextMuted)
                }
                .padding(.top, 4)
                Text("\(formatLiters(dailyWaterGoal)) L hedefin %\(Int(pct*100))")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.pulseTextMuted)
                    .padding(.top, 2)

                Spacer(minLength: 12)

                VStack(spacing: 8) {
                    WaterStatPill(label: "Kalan", value: "\(remainingML) ml")
                    WaterStatPill(label: "Sıradaki hatırlatma", value: nextReminder)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.pulseSurface)
        )
        .pulseCardShadow()
    }

    // MARK: - Hourly card
    private var hourlyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Saatlik dağılım")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(-0.3)
                Spacer()
                Text("06 — 22")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.pulseTextMuted)
            }
            .padding(.horizontal, 4)

            HourlyTimeline(entriesByHour: entriesByHour)
        }
        .padding(.horizontal, 14).padding(.top, 14).padding(.bottom, 10)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.pulseSurface)
        )
        .pulseSoftShadow()
    }

    // MARK: - Quick add
    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hızlı Ekle")
                .font(PulseType.cardTitle).tracking(-0.4)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10),
                                GridItem(.flexible(), spacing: 10)],
                      spacing: 10) {
                ForEach(presets, id: \.ml) { item in
                    Button {
                        addWater(ml: item.ml)
                    } label: {
                        HStack(spacing: 12) {
                            ContainerGlyph(kind: item.kind)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.label)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(Color.pulseText)
                                HStack(alignment: .firstTextBaseline, spacing: 3) {
                                    Text("\(item.ml)")
                                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                                        .tracking(-0.4)
                                        .foregroundStyle(Color.pulseWaterDeep)
                                    Text("ml")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(Color.pulseTextMuted)
                                }
                            }
                            Spacer()
                            ZStack {
                                Circle().fill(Color.pulseWater)
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .heavy))
                                    .foregroundStyle(.white)
                            }
                            .frame(width: 28, height: 28)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.pulseSurface)
                        )
                        .pulseSoftShadow()
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                showCustomEntry = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "pencil")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Özel miktar gir")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(Color.pulseWaterDeep)
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.pulseWaterSoft)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color.pulseWater.opacity(0.4),
                                              style: StrokeStyle(lineWidth: 1, dash: [4]))
                        )
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 0)
        }
    }

    // MARK: - Last entries
    private var lastEntriesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Son Kayıtlar")
                .font(PulseType.cardTitle).tracking(-0.4)

            if todaysEntries.isEmpty {
                Text("Henüz kayıt yok")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.pulseTextMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
                    .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color.pulseSurface))
                    .pulseSoftShadow()
            } else {
                VStack(spacing: 0) {
                    let recent = Array(todaysEntries.suffix(4).reversed())
                    ForEach(Array(recent.enumerated()), id: \.offset) { idx, e in
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.pulseWaterSoft)
                                Image(systemName: "drop.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.pulseWater)
                            }
                            .frame(width: 36, height: 36)

                            Text("\(e.amountML) ml")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                            Spacer()
                            Text(String(format: "%02d:00", e.hour))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.pulseTextMuted)
                            Button {
                                entryToDelete = e
                            } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color.pulseTextMuted.opacity(0.6))
                            }
                            .buttonStyle(.plain)
                            .padding(.leading, 8)
                        }
                        .padding(.horizontal, 12).padding(.vertical, 11)
                        if idx < recent.count - 1 {
                            Divider().background(Color.pulseDivider)
                        }
                    }
                }
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.pulseSurface)
                )
                .pulseSoftShadow()
            }
        }
    }

    // MARK: - Custom Entry Sheet
    private var customEntrySheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    TextField("0", text: $customAmount)
                        .keyboardType(.numberPad)
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.pulseWater)
                    Text("ml")
                        .font(.title2)
                        .foregroundStyle(Color.pulseTextMuted)
                }
                .padding(.top, 40)
                Spacer()
            }
            .navigationTitle("Özel Miktar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        customAmount = ""
                        showCustomEntry = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ekle") {
                        if let val = Int(customAmount), val > 0 {
                            addWater(ml: val)
                        }
                        customAmount = ""
                        showCustomEntry = false
                    }
                    .fontWeight(.semibold)
                    .disabled(Int(customAmount) == nil || customAmount.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Helpers
    private func formatLiters(_ ml: Double) -> String {
        String(format: "%.1f", ml / 1000.0)
    }
    private var nextReminder: String {
        "—"
    }
    private func addWater(ml: Int) {
        let entry = WaterEntry(amount: Double(ml), date: Date())
        modelContext.insert(entry)
        try? modelContext.save()
    }
}

#Preview {
    NavigationStack { WaterView() }
        .modelContainer(for: [WaterEntry.self], inMemory: true)
}
