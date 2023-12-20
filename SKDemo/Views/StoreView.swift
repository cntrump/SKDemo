/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The view for the store.
*/

import SwiftUI
import StoreKit

struct StoreView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        List {
            Section("Cars") {
                ForEach(store.cars) { car in
                    ListCellView(product: car)
                }
            }
            .listStyle(GroupedListStyle())

            SubscriptionsView()

            Section("Navigation: Non-Renewing Subscription") {
                ForEach(store.nonRenewables) { product in
                    ListCellView(product: product, purchasingEnabled: store.purchasedSubscriptions.isEmpty)
                }
            }
            .listStyle(GroupedListStyle())

            Button("Restore Purchases", action: {
                Task {
                    //This call displays a system prompt that asks users to authenticate with their App Store credentials.
                    //Call this function only in response to an explicit user action, such as tapping a button.
                    try? await AppStore.sync()
                }
            })

        }
        .navigationTitle("Shop")
    }
}

struct StoreView_Previews: PreviewProvider {
    @StateObject static var store = Store()
    
    static var previews: some View {
        StoreView()
            .environmentObject(store)
    }
}
