//
//  AdMobCollectionViewCell.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 16. 3. 2025..
//

import UIKit
import GoogleMobileAds

class AdMobCollectionViewCell: UICollectionViewCell {
    
    private var adUnitID: String?
    private var bannerView: GADBannerView!
    
    var onAdLoadFailed: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configure(adUnitID: String) {
        self.adUnitID = adUnitID
        let cachedBanner = AdManager.shared.bannerView(for: adUnitID, adSize: GADAdSizeMediumRectangle) { [weak self] in
            self?.onAdLoadFailed?()
        }
        
        cachedBanner.removeFromSuperview()
        cachedBanner.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(cachedBanner)
        NSLayoutConstraint.activate([
            cachedBanner.topAnchor.constraint(equalTo: topAnchor),
            cachedBanner.leadingAnchor.constraint(equalTo: leadingAnchor),
            cachedBanner.trailingAnchor.constraint(equalTo: trailingAnchor),
            cachedBanner.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        self.bannerView = cachedBanner
    }
}
