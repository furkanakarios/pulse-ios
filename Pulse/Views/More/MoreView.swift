import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: HabitsView()) {
                        Label("Alışkanlıklar", systemImage: "checkmark.circle.fill")
                    }
                    NavigationLink(destination: PlansView()) {
                        Label("Planlar", systemImage: "list.bullet.clipboard")
                    }
                    NavigationLink(destination: NotesView()) {
                        Label("Sağlık Notları", systemImage: "note.text")
                    }
                }
            }
            .navigationTitle("Daha Fazla")
        }
    }
}
