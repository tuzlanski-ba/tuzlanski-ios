//
//  NewestViewController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 11. 11. 2023..
//

import UIKit

class LatestViewController: UIViewController {

    // MARK: - UI Components
    
    private lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewCompositionalLayout { [unowned self] index, environment in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.separatorConfiguration.topSeparatorVisibility = .hidden
            configuration.separatorConfiguration.bottomSeparatorVisibility = .automatic
            configuration.separatorConfiguration.bottomSeparatorInsets = .zero
            configuration.headerTopPadding = 0
            
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
            
            let sectionBackground = NSCollectionLayoutDecorationItem.background(
                elementKind: SectionBackgroundDecorationView.kind)
            section.decorationItems = [sectionBackground]
            
            return section
        }
        
        layout.register(SectionBackgroundDecorationView.self, forDecorationViewOfKind: SectionBackgroundDecorationView.kind)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).forAutoLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ArticleCollectionViewCell.self, forCellWithReuseIdentifier: ArticleCollectionViewCell.identifier)
        collectionView.backgroundColor = .screenBackground
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        return collectionView
    }()
    
    // MARK: - Properties
    
    private var fetchDataSource: FetchDataSource
    private var articles: [ListArticle] = []
    private var page = 0
    private var isFetching = false
    private var canFetchMore = true
    
    // MARK: - Lifecycle
    
    init(fetchDataSource: any FetchDataSource) {
        self.fetchDataSource = fetchDataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let name = fetchDataSource.name {
            navigationItem.title = name
        }
        
        NotificationCenter.observe(notification: UIApplication.willEnterForegroundNotification) { [weak self] _ in
            self?.reloadData(refreshControl: self?.collectionView.refreshControl ?? UIRefreshControl())
        }
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        if articles.isEmpty {
            collectionView.refreshControl?.beginRefreshing()
            loadNextPage()
        }
    }
    
    override func loadView() {
        view = UIView.screen()
        view.addSubview(collectionView)
        collectionView.pin(to: view)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Private methods
    
    private func loadNextPage() {
        guard !isFetching && canFetchMore else { return }
        isFetching = true
        Task {
            do {
                page += 1
                let articles = try await fetchDataSource.fetch(page: page)
                
                if articles.count < TuzlanskiHttpClient.pageLimit {
                    canFetchMore = false
                }
                
                await MainActor.run {
                    self.articles.append(contentsOf: articles)
                    if page == 1 {
                        collectionView.internal_reload()
                    } else {
                        collectionView.reloadData()
                        collectionView.refreshControl?.endRefreshing()
                    }
                    isFetching = false
                }
            } catch {
                print(error)
                collectionView.refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc private func reloadData(refreshControl: UIRefreshControl) {
        isFetching = true
        canFetchMore = true
        page = 0
        
        Task {
            do {
                page += 1
                let articles = try await fetchDataSource.fetch(page: page)
                
                if articles.count < TuzlanskiHttpClient.pageLimit {
                    canFetchMore = false
                }
                
                await MainActor.run {
                    self.articles = articles
                    collectionView.reloadData()
                    isFetching = false
                    collectionView.refreshControl?.endRefreshing()
                }
            } catch {
                print(error)
                collectionView.refreshControl?.endRefreshing()
            }
        }
    }
}

// MARK: - UICollectionView delegates

extension LatestViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if articles.count - 5 == indexPath.row {
            loadNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleCollectionViewCell.identifier, for: indexPath) as! ArticleCollectionViewCell
        cell.configure(article: articles[indexPath.row], displayTimeOnImage: true)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let articleViewController = ArticleViewController(listArticle: articles[indexPath.row])
        navigationController?.pushViewController(articleViewController, animated: true)
    }
}

// MARK: - ScrollableViewController

extension LatestViewController: ScrollableViewController {
    
    func scrollToTop() {
        if collectionView.isAtTop {
            collectionView.refreshControl?.beginRefreshing()
            collectionView.setContentOffset(CGPoint(x: 0, y: collectionView.contentOffset.y - (collectionView.refreshControl?.frame.size.height ?? 0)), animated: true)
            reloadData(refreshControl: collectionView.refreshControl ?? UIRefreshControl())
            return
        }
        
        guard !articles.isEmpty else { return }
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }
}
