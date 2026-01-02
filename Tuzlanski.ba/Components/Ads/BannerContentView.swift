//
//  BannerContentView.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 16. 3. 2025..
//


import GoogleMobileAds
import SwiftUI

struct BannerViewContainer: UIViewRepresentable {
    let adUnitID: String
    let adSize: GADAdSize
    @Binding var isBannerVisible: Bool
    
    init(adUnitID: String, adSize: GADAdSize, bannerVisible: Binding<Bool>) {
        self.adUnitID = adUnitID
        self.adSize = adSize
        self._isBannerVisible = bannerVisible
    }
    
    func makeUIView(context: Context) -> UIView {
        // Wrap the GADBannerView in a UIView. GADBannerView automatically reloads a new ad when its
        // frame size changes; wrapping in a UIView container insulates the GADBannerView from size
        // changes that impact the view returned from makeUIView.
        let view = UIView()
        let bannerView = context.coordinator.bannerView
        bannerView.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController
        bannerView.load(GADRequest())
        view.addSubview(bannerView)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.bannerView.adSize = adSize
    }
    
    func makeCoordinator() -> BannerCoordinator {
        return BannerCoordinator(self)
    }
    
    class BannerCoordinator: NSObject, GADBannerViewDelegate {
        
        private(set) lazy var bannerView: GADBannerView = {
            let banner = GADBannerView(adSize: parent.adSize)
            banner.adUnitID = parent.adUnitID
            banner.delegate = self

            return banner
        }()
        
        let parent: BannerViewContainer
        
        init(_ parent: BannerViewContainer) {
            self.parent = parent
        }
        
        // MARK: - GADBannerViewDelegate methods
        
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            print("(\(self.parent.adUnitID) DID RECEIVE AD")
            DispatchQueue.main.async {
                self.parent.isBannerVisible = true
            }
        }
        
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("(\(self.parent.adUnitID) FAILED TO RECEIVE AD: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.parent.isBannerVisible = false
            }
        }
    }
}
