import SwiftUI

struct ExerciseView: View {
    var body: some View {
        NavigationStack {
            Text("Egzersiz")
                .font(.title2)
                .foregroundStyle(.secondary)
            .navigationTitle("Egzersiz")
        }
    }
}

#Preview {
    ExerciseView()
}
