import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingItem: BoilerEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.items) { item in
                        Button {
                            editingItem = item
                        } label: {
                            row(for: item)
                        }
                        .accessibilityIdentifier("row_\(item.id.uuidString)")
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Boilerlog")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showingSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                EditSheet(item: nil) { newItem in
                    if !store.add(newItem) {
                        showingPaywall = true
                    }
                }
            }
            .sheet(item: $editingItem) { item in
                EditSheet(item: item) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)
    }

    @ViewBuilder
    private func row(for item: BoilerEntry) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Entry")
                .font(Theme.headlineFont)
                .foregroundStyle(.white)
            Text(item.id.uuidString.prefix(8))
                .font(Theme.captionFont)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.vertical, 4)
    }
}

private struct EditSheet: View {
    @Environment(\.dismiss) var dismiss
    @State var draft: BoilerEntry
    var onSave: (BoilerEntry) -> Void
    @FocusState private var focused: Bool

    init(item: BoilerEntry?, onSave: @escaping (BoilerEntry) -> Void) {
        _draft = State(initialValue: item ?? BoilerEntry())
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Pressure (bar)", value: $draft.pressureBar, format: .number)
                    .keyboardType(.decimalPad)
                Toggle("Radiators bled", isOn: $draft.bled)
                DatePicker("Date", selection: $draft.date, displayedComponents: .date)
                TextField("Notes", text: $draft.notes)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focused = false
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle("Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("editCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(draft)
                        dismiss()
                    }
                    .accessibilityIdentifier("editSaveButton")
                }
            }
        }
    }
}
