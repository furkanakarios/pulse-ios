import SwiftUI
import SwiftData

struct WaterView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<WaterEntry> { _ in true }, sort: \WaterEntry.date, order: .reverse)
    private var allEntries: [WaterEntry]

    @State private var showCustomEntry = false
    @State private var customAmount: String = ""

    let dailyGoal: Double = 2500

    private var todayEntries: [WaterEntry] {
        allEntries.filter { Calendar.current.isDateInToday($0.date) }
    }

    private var todayTotal: Double {
        todayEntries.reduce(0) { $0 + $1.amount }
    }

    private var progress: Double {
        min(todayTotal / dailyGoal, 1.0)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    progressSection
                    quickAddSection
                    if !todayEntries.isEmpty {
                        todayLogSection
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Su")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showCustomEntry) {
                customEntrySheet
            }
        }
    }

    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.15), lineWidth: 16)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.5), value: progress)
                VStack(spacing: 4) {
                    Text(String(format: "%.0f", todayTotal))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.blue)
                    Text("ml")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 180, height: 180)

            VStack(spacing: 4) {
                Text(String(format: "Hedef: %.0f ml", dailyGoal))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(String(format: "Kalan: %.0f ml", max(dailyGoal - todayTotal, 0)))
                    .font(.caption)
                    .foregroundStyle(progress >= 1.0 ? .green : .secondary)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Quick Add Section
    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hızlı Ekle")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach([150.0, 200.0, 250.0, 300.0, 400.0, 500.0], id: \.self) { amount in
                    Button {
                        addWater(amount: amount)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "drop.fill")
                                .font(.title3)
                                .foregroundStyle(.blue)
                            Text("\(Int(amount)) ml")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                showCustomEntry = true
            } label: {
                Label("Özel Miktar Gir", systemImage: "pencil")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Today Log
    private var todayLogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bugünkü Kayıtlar")
                .font(.headline)

            ForEach(todayEntries) { entry in
                HStack {
                    Image(systemName: "drop.fill")
                        .foregroundStyle(.blue)
                        .frame(width: 32)
                    Text(String(format: "%.0f ml", entry.amount))
                        .font(.subheadline)
                    Spacer()
                    Text(entry.date, format: .dateTime.hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        modelContext.delete(entry)
                    } label: {
                        Label("Sil", systemImage: "trash")
                    }
                }
            }
        }
    }

    // MARK: - Custom Entry Sheet
    private var customEntrySheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    TextField("Miktar (ml)", text: $customAmount)
                        .keyboardType(.numberPad)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
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

    // MARK: - Actions
    private func addWater(amount: Double) {
        let entry = WaterEntry(amount: amount)
        modelContext.insert(entry)
    }
}

#Preview {
    WaterView()
        .modelContainer(for: [WaterEntry.self], inMemory: true)
}
