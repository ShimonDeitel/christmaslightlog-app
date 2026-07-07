import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let proProductID = "christmaslightlog_pro_monthly"

    @Published var isPro: Bool = false
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                await self?.handle(update: update)
            }
        }
        Task { await refresh() }
    }

    deinit {
        updatesTask?.cancel()
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await Product.products(for: [Self.proProductID])
        } catch {
            errorMessage = error.localizedDescription
        }
        await refreshEntitlements()
    }

    func purchasePro() async {
        guard let product = products.first(where: { $0.id == Self.proProductID }) else { return }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await refreshEntitlements()
                }
            default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    private func handle(update: VerificationResult<Transaction>) async {
        if case .verified(let transaction) = update {
            await transaction.finish()
            await refreshEntitlements()
        }
    }

    private func refreshEntitlements() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == Self.proProductID {
                active = true
            }
        }
        isPro = active
    }
}
