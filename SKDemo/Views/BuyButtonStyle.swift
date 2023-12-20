/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The style of the product buttons that display in the store view.
*/

import StoreKit
import SwiftUI

struct BuyButtonStyle: ButtonStyle {
    let isPurchased: Bool

    init(isPurchased: Bool = false) {
        self.isPurchased = isPurchased
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        var bgColor: Color = isPurchased ? Color.green : Color.blue
        bgColor = configuration.isPressed ? bgColor.opacity(0.7) : bgColor.opacity(1)

        return configuration.label
            .frame(width: 50)
            .padding(10)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

struct BuyButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Button(action: {}) {
                Text("Buy")
                    .foregroundColor(.white)
                    .bold()
            }
            .buttonStyle(BuyButtonStyle())
            .previewDisplayName("Normal")
            
            Button(action: {}) {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
            }
            .buttonStyle(BuyButtonStyle(isPurchased: true))
            .previewDisplayName("Purchased")
        }
    }
}
