import SwiftUI

struct WaterView: View {
    var body: some View {
        NavigationStack {
            Text("Su Takibi")
                .font(.title2)
                .foregroundStyle(.secondary)
            .navigationTitle("Su")
        }
    }
}

#Preview {
    WaterView()
}
