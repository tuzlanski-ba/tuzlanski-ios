//
//  AdMobCollectionViewCell.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 16. 3. 2025..
//

import UIKit
import GoogleMobileAds

class AdMobCollectionViewCell: UICollectionViewCell {
    
    var adUnitID: String?
    var bannerView: GADBannerView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupBannerView() {
        // For adaptive banners, compute the ad size based on the current cell width.
        // You might use UIScreen.main.bounds.width if your cell spans the full width.
        let adWidth = UIScreen.main.bounds.width
        let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(adWidth)
        
        bannerView = GADBannerView(adSize: adSize)
        bannerView.adUnitID = adUnitID
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(bannerView)
        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bannerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bannerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        bannerView.load(GADRequest())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(contentView.bounds.width)
        bannerView.adSize = adSize
    }
    
    func configure(adUnitID: String) {
        guard self.adUnitID == nil else { return }
        self.adUnitID = adUnitID
        setupBannerView()
    }
}
