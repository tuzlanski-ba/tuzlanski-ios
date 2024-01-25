//
//  GalleryViewController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 21. 1. 2024..
//

import UIKit

public class GalleryViewController: UIViewController {
    
    // MARK: - UI Components
    
    private lazy var imageCollectionView: UICollectionView = {
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout).forAutoLayout()
        collectionView.register(GalleryImageTableViewCell.self, forCellWithReuseIdentifier: GalleryImageTableViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.contentSize = CGSize(width: 1000.0, height: 1.0)
        
        return collectionView
    }()
    
    private lazy var pageControlLabel: UILabel = {
        let pageControlLabel = UILabel().forAutoLayout()
        pageControlLabel.numberOfLines = 1
        pageControlLabel.font = .Montserrat(.semibold, size: 13)
        pageControlLabel.textColor = .white
        
        return pageControlLabel
    }()
    
    private lazy var containerView: UIView = {
        let containerView = UIView().forAutoLayout()
        containerView.backgroundColor = .black.withAlphaComponent(0.7)
        containerView.layer.cornerRadius = 10
        containerView.addSubview(pageControlLabel)
        
        return containerView
    }()
    
    private lazy var closeButton: UIButton = {
        let closeButton = UIButton(type: .system).forAutoLayout()
        closeButton.setImage(UIImage(named: "close"), for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        
        return closeButton
    }()
    
    // MARK: - Properties
    
    public var numberOfImages: Int {
        return collectionView(imageCollectionView, numberOfItemsInSection: 0)
    }
    
    public var currentPage: Int {
        set(page) {
            if page < numberOfImages {
                scrollToImage(withIndex: page, animated: false)
            } else {
                scrollToImage(withIndex: numberOfImages - 1, animated: false)
            }
            self.updatePageControl()
        }
        get {
            pageBeforeRotation = Int(imageCollectionView.contentOffset.x / imageCollectionView.frame.size.width)
            return Int(imageCollectionView.contentOffset.x / imageCollectionView.frame.size.width)
        }
    }
    
    private var deviceInRotation = false
    private var pageBeforeRotation: Int = 0
    private var currentIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    private var flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    private var images: [GalleryImage]
    private var currentIndex: Int
    
    // MARK: - Lifecycle
    
    init(images: [GalleryImage], currentIndex: Int) {
        self.images = images
        self.currentIndex = currentIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.images = []
        self.currentIndex = 0
        super.init(coder: aDecoder)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        flowLayout.itemSize = view.bounds.size
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        flowLayout.itemSize = view.bounds.size
        imageCollectionView.collectionViewLayout.invalidateLayout()
        
        if pageBeforeRotation >= 0 {
            scrollToImage(withIndex: pageBeforeRotation, animated: false)
        }
        
        UIView.performWithoutAnimation {
            imageCollectionView.reloadItems(at: [IndexPath(item: pageBeforeRotation, section: 0)])
        }
        
        if currentIndex > 0 {
            currentPage = currentIndex
            currentIndex = -1
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        overrideUserInterfaceStyle = .dark
        
        view.addSubview(imageCollectionView)
        imageCollectionView.pin(to: view)
        
        setupPageControl()
        setupGestureRecognizers()
        updatePageControl()
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        if currentPage < 0 {
            currentPage = 0
        }
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.imageCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    // MARK: Gesture Handlers
    
    private func setupGestureRecognizers() {
        let panGesture = PanDirectionGestureRecognizer(direction: PanDirection.vertical, target: self, action: #selector(wasDragged(_:)))
        imageCollectionView.addGestureRecognizer(panGesture)
        imageCollectionView.isUserInteractionEnabled = true
    }
    
    @objc private func wasDragged(_ gesture: PanDirectionGestureRecognizer) {
        guard let image = gesture.view else { return }
        
        let translation = gesture.translation(in: self.view)
        image.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY + translation.y)
        
        let yFromCenter = image.center.y - self.view.bounds.midY
        
        let alpha = 1 - abs(yFromCenter / self.view.bounds.midY)
        self.view.backgroundColor = view.backgroundColor?.withAlphaComponent(alpha)
        
        if gesture.state == UIGestureRecognizer.State.ended {
            
            var swipeDistance: CGFloat = 0
            let swipeBuffer: CGFloat = 50
            var animateImageAway = false
            
            if yFromCenter > -swipeBuffer && yFromCenter < swipeBuffer {
                // reset everything
                UIView.animate(withDuration: 0.25, animations: {
                    self.view.backgroundColor = self.view.backgroundColor?.withAlphaComponent(1.0)
                    image.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
                })
            } else if yFromCenter < -swipeBuffer {
                swipeDistance = 0
                animateImageAway = true
            } else {
                swipeDistance = self.view.bounds.height
                animateImageAway = true
            }
            
            if animateImageAway {
                if self.modalPresentationStyle == .custom {
                    self.dismiss(animated: true)
                    return
                }
                
                UIView.animate(withDuration: 0.35, animations: {
                    self.view.alpha = 0
                    image.center = CGPoint(x: self.view.bounds.midX, y: swipeDistance)
                }, completion: { (complete) in
                    self.dismiss(animated: true)
                })
            }
            
        }
    }
    
    // MARK: Private Methods
    
    @objc private func closeButtonPressed() {
        dismiss(animated: true)
    }
    
    private func setupPageControl() {
        view.addSubview(containerView)
        view.addSubview(closeButton)
        
        pageControlLabel.pin(to: containerView, padding: .init(top: 8, left: 10, bottom: -8, right: -10))
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -22),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            
            containerView.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            containerView.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -16),
        ])
    }
    
    private func updatePageControl() {
        pageControlLabel.text = "\(currentPage + 1) / \(numberOfImages)"
    }
    
    private func scrollToImage(withIndex: Int, animated: Bool = false) {
        imageCollectionView.isPagingEnabled = false
        imageCollectionView.scrollToItem(at: IndexPath(item: withIndex, section: 0), at: .centeredHorizontally, animated: animated)
        imageCollectionView.isPagingEnabled = true
        imageCollectionView.relayout()
    }
    
    fileprivate func getImage(currentPage: Int) -> URL {
        return URL(string: images[currentPage].styles.original)!
    }
}

// MARK: UICollectionViewDataSource

extension GalleryViewController: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ imageCollectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    public func collectionView(_ imageCollectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: GalleryImageTableViewCell.identifier, for: indexPath) as! GalleryImageTableViewCell
        cell.imageURL = getImage(currentPage: indexPath.row)
        cell.contentView.relayout()
        return cell
    }
}

// MARK: UICollectionViewDelegate

extension GalleryViewController: UICollectionViewDelegate {
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // If the scroll animation ended, update the page control to reflect the current page we are on
        updatePageControl()
    }
}

// MARK: UIGestureRecognizerDelegate

extension GalleryViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return otherGestureRecognizer is UITapGestureRecognizer &&
        gestureRecognizer is UITapGestureRecognizer &&
        otherGestureRecognizer.view is GalleryImageTableViewCell &&
        gestureRecognizer.view == imageCollectionView
    }
}
