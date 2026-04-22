import SwiftUI
import SwiftData

struct WaterView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<WaterEntry> { _ in true }, sort: \WaterEntry.date, order: .reverse)
    private var allEntries: [WaterEntry]

    @State private var showCustomEntry = false
    @State private var customAmount: String = ""

    @AppStorage("dailyWaterGoal") private var dailyGoal: Double = 2500

    private var todayEntries: [WaterEntry] {
        allEntries.filter { Calendar.current.isDateInToday($0.date) }
    }

    private var todayTotal: Double {
        todayEntries.reduce(0) { $0 + $1.amount }
    }

    private var progress: Double {
        min(todayTotal / dailyGoal, 1.0)
    }

    private var isGoalReached: Bool { progress >= 1.0 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    progressSection
                    quickAddSection
                    if !todayEntries.isEmpty {
                        logSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Su")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showCustomEntry) {
                customEntrySheet
            }
        }
    }

    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(
                        isGoalReached ? Color.green.opacity(0.15) : Color.pulseAccent.opacity(0.12),
                        lineWidth: 18
                    )
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        isGoalReached ? Color.green : Color.pulseAccent,
                        style: StrokeStyle(lineWidth: 18, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.5, dampingFraction: 0.75), value: progress)

                VStack(spacing: 4) {
                    Text(String(format: "%.0f", todayTotal))
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .foregroundStyle(isGoalReached ? .green : Color.pulseAccent)
                        .contentTransition(.numericText())
                        .animation(.easeOut(duration: 0.3), value: todayTotal)
                    Text("ml")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 190, height: 190)
            .shadow(color: (isGoalReached ? Color.green : Color.pulseAccent).opacity(0.18), radius: 20, x: 0, y: 8)
            .padding(.top, 8)

            HStack(spacing: 24) {
                statPill(label: "Hedef", value: String(format: "%.0f ml", dailyGoal))
                statPill(label: "Kalan", value: String(format: "%.0f ml", max(dailyGoal - todayTotal, 0)),
                         highlight: isGoalReached)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
    }

    private func statPill(label: String, value: String, highlight: Bool = false) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(highlight ? .green : Color.pulseAccent)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 90)
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(Color(.secondarySystemBackground))
        .clipShape(Capsule())
    }

    // MARK: - Quick Add Section
    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Hızlı Ekle")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.primary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach([150.0, 200.0, 250.0, 300.0, 400.0, 500.0], id: \.self) { amount in
                    Button { addWater(amount: amount) } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(Color.pulseAccentSoft)
                                    .frame(width: 40, height: 40)
                                Image(systemName: "drop.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Color.pulseAccent)
                            }
                            Text("\(Int(amount))")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                            Text("ml")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }

            Button { showCustomEntry = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Özel Miktar Gir")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(Color.pulseAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.pulseAccentSoft)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
    }

    // MARK: - Log Section
    private var logSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Bugünkü Kayıtlar")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.primary)

            VStack(spacing: 1) {
                ForEach(todayEntries) { entry in
                    waterEntryRow(entry)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
    }

    private func waterEntryRow(_ entry: WaterEntry) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.pulseAccentSoft)
                    .frame(width: 36, height: 36)
                Image(systemName: "drop.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.pulseAccent)
            }
            Text(String(format: "%.0f ml", entry.amount))
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
            Spacer()
            Text(entry.date, format: .dateTime.hour().minute())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                modelContext.delete(entry)
            } label: {
                Label("Sil", systemImage: "trash")
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
                        .foregroundStyle(Color.pulseAccent)
                    Text("ml")
                        .font(.title2)
                        .foregroundStyle(.secondary)
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
                        if let amount = Double(customAmount), amount > 0 {
                            addWater(amount: amount)
                        }
                        customAmount = ""
                        showCustomEntry = false
                    }
                    .fontWeight(.semibold)
                    .disabled(Double(customAmount) == nil || customAmount.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func addWater(amount: Double) {
        let entry = WaterEntry(amount: amount)
        modelContext.insert(entry)
    }
}

#Preview {
    WaterView()
        .modelContainer(for: [WaterEntry.self], inMemory: true)
}
