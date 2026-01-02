//
//  AdBannerView.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 26. 3. 2025..
//

import SwiftUI
import GoogleMobileAds
import UIKit

struct AdBannerView: UIViewRepresentable {
    let adUnitID: String
    @Binding var isAdVisible: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeMediumRectangle)
        bannerView.adUnitID = adUnitID

        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            print("AdBannerView: Could not find UIWindowScene.")
            return bannerView
        }
        bannerView.rootViewController = scene.windows.first { $0.isKeyWindow }?.rootViewController

        bannerView.delegate = context.coordinator

        bannerView.load(GADRequest())
        print("AdBannerView: makeUIView - Created and attempting load.")
        return bannerView
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {
        print("AdBannerView: updateUIView")
        uiView.backgroundColor = .clear
        if uiView.rootViewController == nil {
             guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
             uiView.rootViewController = scene.windows.first { $0.isKeyWindow }?.rootViewController
             if uiView.rootViewController != nil && !context.coordinator.didLoadAdSuccessfully {
                 print("AdBannerView: updateUIView - RootVC was nil, reloading ad.")
                 uiView.load(GADRequest())
             }
        }
    }

    class Coordinator: NSObject, GADBannerViewDelegate {
        let parent: AdBannerView
        var didLoadAdSuccessfully = false

        init(parent: AdBannerView) {
            self.parent = parent
        }

        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            print("AdBannerView: bannerViewDidReceiveAd - Setting isVisible = true")
            parent.isAdVisible = true
            didLoadAdSuccessfully = true
        }

        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("AdBannerView: didFailToReceiveAdWithError: \(error.localizedDescription) - Setting isVisible = false")
            parent.isAdVisible = false
            didLoadAdSuccessfully = false
        }
    }
}
