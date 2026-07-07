import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Theme.accent)
                Text("Christmas Light Log Pro")
                    .font(Theme.titleFont)
                    .foregroundColor(Theme.textPrimary)
                Text("Photo history & replacement shopping list")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if let product = purchases.products.first {
                    Button {
                        Task { await purchases.purchasePro() }
                    } label: {
                        Text("Subscribe - \(product.displayPrice)/month")
                            .font(Theme.headlineFont)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .accessibilityIdentifier("subscribeButton")
                    .padding(.horizontal)
                } else {
                    ProgressView().tint(Theme.accent)
                }

                Button("Restore Purchases") {
                    Task { await purchases.restore() }
                }
                .accessibilityIdentifier("paywallRestoreButton")
                .foregroundColor(Theme.textSecondary)

                Button("Not now") { dismiss() }
                    .accessibilityIdentifier("paywallDismissButton")
                    .foregroundColor(Theme.textSecondary)
            }
            .padding()
        }
        .task { await purchases.refresh() }
    }
}
