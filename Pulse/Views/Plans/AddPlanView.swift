import SwiftUI
import SwiftData

struct AddPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var notes = ""
    @State private var planType = "Haftalık"
    @State private var startDate = Date.now
    @State private var endDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: .now) ?? .now

    let planTypes = ["Haftalık", "Aylık"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Plan Başlığı") {
                    TextField("Örn: Haftada 5 gün egzersiz", text: $title)
                }

                Section("Tür") {
                    Picker("Tür", selection: $planType) {
                        ForEach(planTypes, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: planType) { updateEndDate() }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                Section("Tarih Aralığı") {
                    DatePicker("Başlangıç", selection: $startDate, displayedComponents: .date)
                        .onChange(of: startDate) { updateEndDate() }
                    DatePicker("Bitiş", selection: $endDate, in: startDate..., displayedComponents: .date)
                }

                Section("Notlar (opsiyonel)") {
                    TextField("Açıklama...", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Yeni Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") { save() }
                        .fontWeight(.semibold)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func updateEndDate() {
        let offset: Calendar.Component = planType == "Haftalık" ? .weekOfYear : .month
        endDate = Calendar.current.date(byAdding: offset, value: 1, to: startDate) ?? endDate
    }

    private func save() {
        let plan = Plan(
            title: title.trimmingCharacters(in: .whitespaces),
            notes: notes.trimmingCharacters(in: .whitespaces),
            startDate: startDate,
            endDate: endDate,
            planType: planType
        )
        modelContext.insert(plan)
        dismiss()
    }
}
