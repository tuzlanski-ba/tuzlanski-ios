//
//  ArticleViewController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 18. 11. 2023..
//

import UIKit
import SwiftUI
import NukeUI

class ObservableArticle: ObservableObject {
    @Published var url: String?
    @Published var listArticle: ListArticle?
    @Published var article: Article?
    
    internal init (url: String) {
        self.url = url
    }
    
    internal init(listArticle: ListArticle, article: Article? = nil) {
        self.listArticle = listArticle
        self.article = article
    }
}

class ArticleViewController: UIViewController {
    
    // MARK: - UI Components
    
    private lazy var textSizeBarButtonItem: UIBarButtonItem = {
        let textSizeBarButtonItem = UIBarButtonItem(image: UIImage(named: "text-size")?.resized(to: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysTemplate), menu: generateTextSizeMenu())
        
        return textSizeBarButtonItem
    }()
    
    private lazy var optionsBarButtonItem: UIBarButtonItem = {
        let optionsBarButtonItem = UIBarButtonItem(image: UIImage(named: "options")?.resized(to: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysTemplate), menu: generateOptionsMenu())
        
        return optionsBarButtonItem
    }()
    
    // MARK: - Properties
    
    private var observableArticle: ObservableArticle
    private let httpClient = TuzlanskiHttpClient()
    private let bookmarkRepository = BookmarkRepository()
    
    // MARK: - Lifecycle
    
    init(url: String) {
        self.observableArticle = ObservableArticle(url: url)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(listArticle: ListArticle) {
        self.observableArticle = ObservableArticle(listArticle: listArticle, article: nil)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = observableArticle.url ?? observableArticle.listArticle?.apiURL ?? ""
        Task {
            do {
                let article = try await httpClient.getArticle(apiURL: url)
                if observableArticle.listArticle == nil {
                    observableArticle.listArticle = article.toListArticle()
                    optionsBarButtonItem.menu = generateOptionsMenu()
                }
                observableArticle.article = article
            } catch {
                print(error)
            }
        }
        
        (navigationController as? SideNavigationController)?.addLogoToCurrentViewController()
        
        self.navigationItem.rightBarButtonItems = [optionsBarButtonItem, textSizeBarButtonItem]
    }
    
    override func loadView() {
        view = UIView.screen()
        
        var articleView = ArticleView(observableArticle: observableArticle)
        articleView.onCategoryPress = { [unowned self] in
            guard let listArticle = observableArticle.listArticle else { return }
            let category = Category(id: listArticle.sectionID, slug: listArticle.section.slug_short, name: listArticle.section.name)
            self.navigationController?.pushViewController(LatestViewController(fetchDataSource: CategoryFetchDataSource(category: category)), animated: true)
        }
        articleView.onTagPress = { [unowned self] tag in
            self.navigationController?.pushViewController(LatestViewController(fetchDataSource: TagFetchDataSource(tag: tag)), animated: true)
        }
        articleView.fetchArticle = { [unowned self] in
            let url = observableArticle.url ?? observableArticle.listArticle?.apiURL ?? ""
            return try await httpClient.getArticle(apiURL: url)
        }
        articleView.onCommentPress = { [unowned self] in
            guard let article = observableArticle.article else { return }
            self.navigationController?.pushViewController(CommentsViewController(article: article), animated: true)
        }
        
        addSwiftUIView(articleView)
    }
    
    // MARK: - Private methods
    
    private func generateTextSizeMenu() -> UIMenu {
        let decreaseAction = UIAction(title: "Smanji", image: UIImage(named: "decrease-text"), identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off) { [weak self] _ in
            AppStorage.articleFontSize = max(AppStorage.articleFontSize - 1, 13)
            NotificationCenter.dispatch(notification: .articleFontSizeChanged)
            self?.textSizeBarButtonItem.menu = self?.generateTextSizeMenu()
        }
        
        let increaseAction = UIAction(title: "Povećaj", image: UIImage(named: "increase-text"), identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off) { [weak self] _ in
            AppStorage.articleFontSize = min(AppStorage.articleFontSize + 1, 20)
            NotificationCenter.dispatch(notification: .articleFontSizeChanged)
            self?.textSizeBarButtonItem.menu = self?.generateTextSizeMenu()
        }
        
        let statusAction = UIAction(title: String(AppStorage.articleFontSize), image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [.disabled], state: .off) { _ in }
        
        let menu = UIMenu(title: "Povećajte ili smanjite veličinu teksta u člancima",  children: [decreaseAction, statusAction, increaseAction])
        if #available(iOS 16.0, *) {
            menu.preferredElementSize = .medium
        }
        
        return menu
    }
    
    private func generateOptionsMenu() -> UIMenu {
        guard let listArticle = observableArticle.listArticle else { return UIMenu() }
        
        let bookmark = bookmarkRepository.bookmark(articleID: listArticle.id)
        
        let bookmarkAction = UIAction(title: "Spremi", image: UIImage(named: "bookmark")) { [weak self] _ in
            guard let self else { return }
            try? bookmarkRepository.save(bookmark: Bookmark(with: listArticle))
            optionsBarButtonItem.menu = generateOptionsMenu()
        }
        
        let unbookmarkAction = UIAction(title: "Ukloni iz spremljenih vijesti", image: UIImage(named: "bookmark-filled")) { [weak self] _ in
            guard let self else { return }
            guard let bookmark else { return }
            bookmarkRepository.remove(bookmark: bookmark)
            optionsBarButtonItem.menu = generateOptionsMenu()
        }
        
        let shareAction = UIAction(title: "Podijeli", image: UIImage(named: "share")) { [weak self] _ in
            self?.shareButtonPressed()
        }
        
        let menu = UIMenu(title: "",  children: [bookmark == nil ? bookmarkAction : unbookmarkAction , shareAction])
        
        return menu
    }
    
    @objc private func shareButtonPressed() {
        guard let listArticle = observableArticle.listArticle else { return }
        let items = [URL(string: listArticle.url)!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
}

struct ArticleView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var observableArticle: ObservableArticle
    
    @State private var webViewHeight: CGFloat = .zero
    
    var onCategoryPress: (() -> Void)?
    var onTagPress: ((Tag) -> Void)?
    var fetchArticle: (() async throws -> Article)?
    var onCommentPress: (() -> Void)?
    
    var body: some View {
        ScrollView {
            Spacer()
                .frame(height: 10)
            VStack(spacing: 4) {
                
                if let listArticle = observableArticle.listArticle {
                    Button {
                        onCategoryPress?()
                    } label: {
                        Text((listArticle.preTitle ?? listArticle.section.path.replacingOccurrences(of: ">", with: "/")).uppercased())
                            .font(Font(UIFont.Montserrat(.bold, size: 13)))
                            .foregroundStyle(Color(UIColor(hex: listArticle.section.color_hex)))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Text(listArticle.title)
                        .font(Font(UIFont.Montserrat(.bold, size: 18)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(Date.formatToFullDate(apiDate: listArticle.publishedAt))
                        .font(Font(UIFont.Montserrat(.semibold, size: 13)))
                        .foregroundStyle(Color(UIColor.systemGray2))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    LazyImage(url: URL(string: listArticle.image.original ?? "")) { state in
                        if let image = state.image {
                            image.resizable().aspectRatio(contentMode: .fit)
                        } else if state.error != nil {
                            Color.red // Indicates an error
                        } else {
                            Color.blue // Acts as a placeholder
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .cornerRadius(8)
                    .padding(.top, 10)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.top, 18)
                }
                
                if let article = observableArticle.article {
                    WebView(text: article.body().wrappedInHTML, dynamicHeight: $webViewHeight)
                        .frame(height: webViewHeight)
                        .padding(.top, 8)
                    if webViewHeight > 0 {
                    Divider()
                            .overlay(Color(UIColor(hex: article.section.color_hex)))
                            .padding(.top, 10)
                        Text("TAGOVI")
                            .font(Font(UIFont.Montserrat(.extraBold, size: 13)))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 10)
                        WrappingHStack(article.tags, id:\.self, lineSpacing: 8) { tag in
                            Button(action: { onTagPress?(tag) }) {
                                Text(tag.name.uppercased())
                                    .font(Font(UIFont.Montserrat(.bold, size: 12)))
                                    .padding(6)
                                    .tint(Color(UIColor(hex: article.section.color_hex)))
                                    .background(Color(UIColor(hex: article.section.color_hex).withAlphaComponent(0.2)))
                                    .cornerRadius(6)
                            }
                        }
                        .padding(.top, 4)
                        Divider()
                            .overlay(Color(UIColor(hex: article.section.color_hex)))
                            .padding(.top, 10)
                        Button(action: { onCommentPress?() }) {
                            Text("KOMENTARI (\(article.commentsCount))")
                                .font(Font(UIFont.Montserrat(.bold, size: 14)))
                                .tint(Color.white)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .frame(height: 40)
                        .background(Color(UIColor(hex: article.section.color_hex)))
                        .cornerRadius(6)
                        .padding(.vertical, 12)
                        Spacer()
                            .frame(height: 10)
                    } else if observableArticle.listArticle != nil {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding(.top, 18)
                    }
                }
            }
            .padding(.horizontal, 16)
            Spacer()
        }
        .refreshable {
            guard let fetchArticle else { return }
            do {
                let article = try await fetchArticle()
                self.observableArticle.article = article
            } catch {
                print("Error while refetching article:", error)
            }
        }
    }
}
