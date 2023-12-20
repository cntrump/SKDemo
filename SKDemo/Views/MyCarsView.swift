/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view showing all the user's purchased cars and subscriptions.
*/

import SwiftUI
import StoreKit

struct MyCarsView: View {
    @StateObject var store: Store = Store()

    var body: some View {
        NavigationView {
            if store.purchasedCars.isEmpty && store.purchasedNonRenewableSubscriptions.isEmpty && store.purchasedSubscriptions.isEmpty {
                VStack {
                    Text("SK Demo App")
                        .bold()
                        .font(.system(size: 50))
                        .padding(.bottom, 20)
                    Text("🏎💨")
                        .font(.system(size: 120))
                        .padding(.bottom, 20)
                    Text("Head over to the shop to get started!")
                        .font(.headline)
                        .padding()
                        .multilineTextAlignment(.center)
                    NavigationLink {
                        StoreView()
                    } label: {
                        Label("Shop", systemImage: "cart")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 300, height: 50, alignment: .center)
                            .background(Color.blue)
                            .cornerRadius(15.0)
                    }
                }
            } else {
                List {
                    Section("My Cars") {
                        if !store.purchasedCars.isEmpty {
                            ForEach(store.purchasedCars) { product in
                                NavigationLink {
                                    ProductDetailView(product: product)
                                } label: {
                                    ListCellView(product: product, purchasingEnabled: false)
                                }
                            }
                        } else {
                            Text("You don't own any car products. \nHead over to the shop to get started!")
                        }
                    }
                    Section("Navigation Service") {
                        if !store.purchasedNonRenewableSubscriptions.isEmpty || !store.purchasedSubscriptions.isEmpty {
                            ForEach(store.purchasedNonRenewableSubscriptions) { product in
                                NavigationLink {
                                    ProductDetailView(product: product)
                                } label: {
                                    ListCellView(product: product, purchasingEnabled: false)
                                }
                            }
                            ForEach(store.purchasedSubscriptions) { product in
                                NavigationLink {
                                    ProductDetailView(product: product)
                                } label: {
                                    ListCellView(product: product, purchasingEnabled: false)
                                }
                            }

                        } else {
                            if let subscriptionGroupStatus = store.subscriptionGroupStatus {
                                if subscriptionGroupStatus == .expired || subscriptionGroupStatus == .revoked {
                                    Text("Welcome Back! \nHead over to the shop to get started!")
                                } else if subscriptionGroupStatus == .inBillingRetryPeriod {
                                    //The best practice for subscriptions in the billing retry state is to provide a deep link
                                    //from your app to https://apps.apple.com/account/billing.
                                    Text("Please verify your billing details.")
                                }
                            } else {
                                Text("You don't own any subscriptions. \nHead over to the shop to get started!")
                            }
                        }
                    }
                    
                    NavigationLink {
                        StoreView()
                    } label: {
                        Label("Shop", systemImage: "cart")
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color.blue)
                }
                
                .navigationTitle("SK Demo App")
            }
        }
        .environmentObject(store)
    }
}

struct MyCarsView_Previews: PreviewProvider {
    static var previews: some View {
        MyCarsView()
    }
}

