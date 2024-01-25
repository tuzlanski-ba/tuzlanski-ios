//
//  GalleryImageTableViewCell.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 22. 1. 2024..
//

import UIKit
import NukeUI

open class GalleryImageTableViewCell: UICollectionViewCell {
    
    var imageURL: URL? {
        didSet {
            imageView.reset()
            configureForNewImage()
        }
    }
    
    open var scrollView: UIScrollView
    public let imageView: LazyImageView
    
    override init(frame: CGRect) {
        imageView = LazyImageView().forAutoLayout()
        imageView.priority = .high
        scrollView = UIScrollView(frame: frame).forAutoLayout()
        
        super.init(frame: frame)
        
        imageView.onCompletion = { [unowned self] result in
            switch result {
            case .success(_):
                contentView.relayout()
                scrollView.relayout()
                imageView.relayout()
                imageView.sizeToFit()
                imageView.imageView.relayout()
                imageView.imageView.sizeToFit()
                setZoomScale()
                scrollViewDidZoom(scrollView)
            case .failure(_):
                print("fail")
            }
        }
        
        contentView.addSubview(scrollView)
        scrollView.pin(to: self)
        
        scrollView.addSubview(imageView)
        imageView.pin(to: scrollView)
        
        scrollView.delegate = self
        
        setupGestureRecognizer()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        imageView.reset()
    }
    
    @objc public func doubleTapAction(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
    func configureForNewImage() {
        imageView.url = imageURL
    }
    
    func relayoutAfterOrientationChange() {
        imageView.reset()
        imageView.url = imageURL
    }
    
    // MARK: Private Methods
    
    private func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
    }
    
    private func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
    }
    
}

// MARK: UIScrollViewDelegate Methods

extension GalleryImageTableViewCell: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        if verticalPadding >= 0 {
            // Center the image on screen
            scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
        } else {
            // Limit the image panning to the screen bounds
            scrollView.contentSize = imageViewSize
        }
    }
}
