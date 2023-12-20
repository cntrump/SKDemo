/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view in the store for subscription products that also displays subscription statuses.
*/

import StoreKit
import SwiftUI

struct SubscriptionsView: View {
    @EnvironmentObject var store: Store

    @State var currentSubscription: Product?
    @State var status: Product.SubscriptionInfo.Status?

    var availableSubscriptions: [Product] {
        store.subscriptions.filter { $0.id != currentSubscription?.id }
    }

    var body: some View {
        Group {
            if let currentSubscription = currentSubscription {
                Section("My Subscription") {
                   ListCellView(product: currentSubscription, purchasingEnabled: false)

                    if let status = status {
                        StatusInfoView(product: currentSubscription,
                                        status: status)
                    }
                }
                .listStyle(GroupedListStyle())
            }

            Section("Navigation: Auto-Renewable Subscription") {
                ForEach(availableSubscriptions) { product in
                    ListCellView(product: product)
                }
            }
            .listStyle(GroupedListStyle())
        }
        .onAppear {
            Task {
                //When this view appears, get the latest subscription status.
                await updateSubscriptionStatus()
            }
        }
        .onChange(of: store.purchasedSubscriptions) { _ in
            Task {
                //When `purchasedSubscriptions` changes, get the latest subscription status.
                await updateSubscriptionStatus()
            }
        }
    }

    @MainActor
    func updateSubscriptionStatus() async {
        do {
            //This app has only one subscription group, so products in the subscriptions
            //array all belong to the same group. The statuses that
            //`product.subscription.status` returns apply to the entire subscription group.
            guard let product = store.subscriptions.first,
                  let statuses = try await product.subscription?.status else {
                return
            }

            var highestStatus: Product.SubscriptionInfo.Status? = nil
            var highestProduct: Product? = nil

            //Iterate through `statuses` for this subscription group and find
            //the `Status` with the highest level of service that isn't
            //in an expired or revoked state. For example, a customer may be subscribed to the
            //same product with different levels of service through Family Sharing.
            for status in statuses {
                switch status.state {
                case .expired, .revoked:
                    continue
                default:
                    let renewalInfo = try store.checkVerified(status.renewalInfo)

                    //Find the first subscription product that matches the subscription status renewal info by comparing the product IDs.
                    guard let newSubscription = store.subscriptions.first(where: { $0.id == renewalInfo.currentProductID }) else {
                        continue
                    }

                    guard let currentProduct = highestProduct else {
                        highestStatus = status
                        highestProduct = newSubscription
                        continue
                    }

                    let highestTier = store.tier(for: currentProduct.id)
                    let newTier = store.tier(for: renewalInfo.currentProductID)

                    if newTier > highestTier {
                        highestStatus = status
                        highestProduct = newSubscription
                    }
                }
            }

            status = highestStatus
            currentSubscription = highestProduct
        } catch {
            print("Could not update subscription status \(error)")
        }
    }
}

struct SubscriptionsView_Previews: PreviewProvider {
    @StateObject static var store = Store()
    @State static var subscription: Product?
    
    static var previews: some View {
        Group {
            // View with no active subscriptions
            SubscriptionsView()
                .previewDisplayName("No active subscriptions")
            
            // View with an active subscription
            if let subscription {
                SubscriptionsView(currentSubscription: subscription, status: nil)
                    .previewDisplayName("With an active subscription")
            }
        }
        .environmentObject(store)
        .task {
            guard let product = store.purchasedSubscriptions.first else {
                return
            }
            subscription = product
        }
    }
}
