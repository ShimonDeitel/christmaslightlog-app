import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingEntry: StrandEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.entries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                    Text(entry.condition).font(Theme.bodyFont)
                    Text(entry.storageBin).font(Theme.bodyFont)
                        }
                        .listRowBackground(Theme.card)
                        .contentShape(Rectangle())
                        .onTapGesture { editingEntry = entry }
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Theme.background)

                if store.entries.isEmpty {
                    Text("No entries yet. Tap + to add your first one.")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.textSecondary)
                }
            }
            .navigationTitle("Christmas Light Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showingSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAdd(isPro: purchases.isPro) {
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
                EntryEditorView(entry: nil) { new in
                    store.add(new)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryEditorView(entry: entry) { updated in
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
}

struct EntryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: StrandEntry
    var onSave: (StrandEntry) -> Void

    init(entry: StrandEntry?, onSave: @escaping (StrandEntry) -> Void) {
        _draft = State(initialValue: entry ?? StrandEntry())
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Condition", text: $draft.condition)
                    .accessibilityIdentifier("field_condition")
                TextField("Bin", text: $draft.storageBin)
                    .accessibilityIdentifier("field_storageBin")
                TextField("Notes", text: $draft.notes)
                    .accessibilityIdentifier("field_notes")
            }
            .navigationTitle("Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(draft)
                        dismiss()
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
}
