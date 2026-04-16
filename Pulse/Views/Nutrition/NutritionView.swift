import SwiftUI

struct NutritionView: View {
    var body: some View {
        NavigationStack {
            Text("Beslenme")
                .font(.title2)
                .foregroundStyle(.secondary)
            .navigationTitle("Beslenme")
        }
    }
}

#Preview {
    NutritionView()
}
