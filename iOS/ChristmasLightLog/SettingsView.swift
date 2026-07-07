import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingPaywall = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    Toggle("Reminders", isOn: $store.settings.remindersEnabled)
                        .accessibilityIdentifier("remindersToggle")
                    Toggle("Compact list", isOn: $store.settings.compactList)
                        .accessibilityIdentifier("compactToggle")
                    Toggle("Show notes inline", isOn: $store.settings.showNotesInline)
                        .accessibilityIdentifier("notesInlineToggle")
                }
                .onChange(of: store.settings) { _, _ in store.saveSettings() }

                Section("Subscription") {
                    if purchases.isPro {
                        Label("Pro active", systemImage: "checkmark.seal.fill")
                            .foregroundColor(Theme.accent)
                    } else {
                        Button("Upgrade to Pro") { showingPaywall = true }
                            .accessibilityIdentifier("upgradeButton")
                    }
                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .accessibilityIdentifier("restoreButton")
                }

                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/christmaslightlog-app/privacy.html")!)
                    Text("Version 1.0")
                        .foregroundColor(Theme.textSecondary)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("settingsDoneButton")
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}
