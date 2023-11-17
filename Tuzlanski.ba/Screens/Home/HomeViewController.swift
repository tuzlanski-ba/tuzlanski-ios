//
//  HomeViewController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 11. 11. 2023..
//

import UIKit

struct HomeData {
    var articles: [ListArticle]
    var category: Category?
}

class HomeViewController: UIViewController {
    
    // MARK: - UI Components
    
    private lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewCompositionalLayout { [unowned self] index, environment in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.separatorConfiguration.topSeparatorVisibility = .hidden
            configuration.separatorConfiguration.bottomSeparatorVisibility = .automatic
            configuration.separatorConfiguration.bottomSeparatorInsets = .zero
            configuration.itemSeparatorHandler = { [weak self] indexPath, sectionSeparatorConfiguration in
                var configuration = sectionSeparatorConfiguration
                let count = self?.homeData[indexPath.section].articles.count ?? 0
                configuration.bottomSeparatorVisibility = indexPath.row == count - 1 ? .hidden : .visible
                return configuration
            }
            configuration.headerTopPadding = 0
            
            var section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
            let sectionSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(60)
            )
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: sectionSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            sectionHeader.pinToVisibleBounds = false
            
            if self.homeData[index].category != nil {
                configuration.headerMode = .supplementary
                section.boundarySupplementaryItems = [sectionHeader]
            }
            
            return section
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).forAutoLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ArticleCollectionViewCell.self, forCellWithReuseIdentifier: ArticleCollectionViewCell.identifier)
        collectionView.register(FeaturedArticleCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedArticleCollectionViewCell.identifier)
        collectionView.register(CategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeaderView.identifier)
        
        return collectionView
    }()
    
    // MARK: - Properties
    
    private let httpClient = TuzlanskiHttpClient()
    
    private var homeData: [HomeData] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                let categories = try await httpClient.fetchCategories()
                let categoriesMap = Dictionary(uniqueKeysWithValues: categories.map{ ($0.slug, $0) })
                
                let indexResponse = try await httpClient.getHomeArticles()
                
                homeData = [
                    .init(articles: indexResponse.top),
                    .init(articles: indexResponse.vijesti, category: categoriesMap["vijesti"]),
                    .init(articles: indexResponse.biznis, category: categoriesMap["biznis"]),
                    .init(articles: indexResponse.sport, category: categoriesMap["sport"]),
                    .init(articles: indexResponse.magazin, category: categoriesMap["magazin"]),
                    .init(articles: indexResponse.lifestyle, category: categoriesMap["lifestyle"]),
                    .init(articles: indexResponse.automoto, category: categoriesMap["automoto"]),
                    .init(articles: indexResponse.scitech, category: categoriesMap["scitech"]),
                    .init(articles: indexResponse.viral, category: categoriesMap["viral"]),
                    .init(articles: indexResponse.promo),
                ]
                
                await MainActor.run {
                    collectionView.reloadData()
                }
            } catch {
                print(error)
            }
        }
    }
    
    override func loadView() {
        view = UIView.screen()
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.pin(to: view)
    }
}

// MARK: - UICollectionView delegates

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return homeData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeData[section].articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedArticleCollectionViewCell.identifier, for: indexPath) as! FeaturedArticleCollectionViewCell
            cell.configure(article: homeData[indexPath.section].articles[indexPath.row])
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleCollectionViewCell.identifier, for: indexPath) as! ArticleCollectionViewCell
        cell.configure(article: homeData[indexPath.section].articles[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeaderView.identifier, for: indexPath) as! CategoryHeaderView
        
        if let category = homeData[indexPath.section].category {
            headerView.configure(category: category)
        }
        
        return headerView
    }
}

