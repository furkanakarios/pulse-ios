import SwiftUI

struct HabitsView: View {
    var body: some View {
        NavigationStack {
            Text("Alışkanlıklar")
                .font(.title2)
                .foregroundStyle(.secondary)
            .navigationTitle("Alışkanlıklar")
        }
    }
}

#Preview {
    HabitsView()
}
