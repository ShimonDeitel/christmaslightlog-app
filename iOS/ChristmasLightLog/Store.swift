import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [StrandEntry] = []
    @Published var settings: AppSettings = AppSettings()

    /// Free tier allows this many entries. Kept comfortably above seed data
    /// so a fresh install never trips the paywall immediately.
    static let freeEntryLimit = 12

    private let fileURL: URL
    private let settingsURL: URL

    init() {
        let supportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: supportDir, withIntermediateDirectories: true)
        fileURL = supportDir.appendingPathComponent("christmaslightlog_entries.json")
        settingsURL = supportDir.appendingPathComponent("christmaslightlog_settings.json")
        load()
    }

    var isAtFreeLimit: Bool {
        entries.count >= Store.freeEntryLimit
    }

    func canAdd(isPro: Bool) -> Bool {
        isPro || entries.count < Store.freeEntryLimit
    }

    func add(_ entry: StrandEntry) {
        entries.insert(entry, at: 0)
        save()
    }

    func update(_ entry: StrandEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: StrandEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    private func seedIfNeeded() {
        guard entries.isEmpty else { return }
        entries = [
        StrandEntry(condition: "Working", storageBin: "Bin A - Garage shelf", notes: "200 warm white, roofline"),
        StrandEntry(condition: "3 bulbs out", storageBin: "Bin B - Attic", notes: "Icicle strand, porch")
        ]
        save()
    }

    func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([StrandEntry].self, from: data) {
            entries = decoded
        }
        seedIfNeeded()
        if let data = try? Data(contentsOf: settingsURL),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            try? data.write(to: settingsURL, options: .atomic)
        }
    }
}

struct AppSettings: Codable, Equatable {
    var remindersEnabled: Bool = true
    var compactList: Bool = false
    var showNotesInline: Bool = true
}
