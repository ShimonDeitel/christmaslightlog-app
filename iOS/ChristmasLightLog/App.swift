import SwiftUI

@main
struct ChristmasLightLogApp: App {
    @StateObject private var store = Store()
    @StateObject private var purchases = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(purchases)
                .preferredColorScheme(.dark)
        }
    }
}
