//
//  AdManager.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 18. 3. 2025..
//

import UIKit
import GoogleMobileAds

class AdManager: NSObject {
    struct CachedBanner {
        var banner: GADBannerView
        var onFail: () -> Void
    }
    
    static let shared = AdManager()
    private var cache: [String: CachedBanner] = [:]
    
    func bannerView(for adUnitID: String, adSize: GADAdSize, onFail: @escaping () -> Void) -> GADBannerView {
        if let cachedBanner = cache[adUnitID] {
            return cachedBanner.banner
        } else {
            let banner = GADBannerView(adSize: adSize)
            banner.adUnitID = adUnitID
            banner.rootViewController = UIApplication.shared.windows.first?.rootViewController
            banner.delegate = self
            banner.load(GADRequest())
            cache[adUnitID] = CachedBanner(banner: banner, onFail: onFail)
            return banner
        }
    }
    
    func resetBannerCache(for adUnitID: String) {
        print("AdManager: Resetting banner cache for: \(adUnitID)")
        cache.removeValue(forKey: adUnitID)
    }
    
    func resetAll() {
        cache.removeAll()
    }
}

// MARK: - GADBannerViewDelegate

extension AdManager: GADBannerViewDelegate {
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("AdManager: (\(bannerView.adUnitID ?? "")) DID RECEIVE AD")
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: any Error) {
        print("AdManager: (\(bannerView.adUnitID ?? "")) FAILED TO RECEIVE AD: \(error.localizedDescription)")
        if let adUnitID = bannerView.adUnitID {
            cache[adUnitID]?.onFail()
            cache.removeValue(forKey: adUnitID)
        }
    }
}
