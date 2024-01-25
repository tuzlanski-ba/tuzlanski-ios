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
    @Published var relatedArticles: [ListArticle] = []
    
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
    
    private lazy var optionsBarButtonItem: UIBarButtonItem = {
        let optionsBarButtonItem = UIBarButtonItem(image: UIImage(named: "options")?.resized(to: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysTemplate), menu: generateOptionsMenu())
        
        return optionsBarButtonItem
    }()
    
    private lazy var shareBarButtonItem: UIBarButtonItem = {
        let shareBarButtonItem = UIBarButtonItem(image: UIImage(named: "share")?.resized(to: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(shareButtonPressed))
        
        return shareBarButtonItem
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
                var articleResponse = try await httpClient.getArticle(apiURL: url)
                articleResponse.article._images = articleResponse.article.images.sorted { $0.is_main > $1.is_main }
                if observableArticle.listArticle == nil {
                    observableArticle.listArticle = articleResponse.article.toListArticle()
                    optionsBarButtonItem.menu = generateOptionsMenu()
                }
                observableArticle.relatedArticles = articleResponse.related
                observableArticle.article = articleResponse.article
            } catch {
                print(error)
            }
        }
        
        (navigationController as? SideNavigationController)?.addLogoToCurrentViewController()
        
        self.navigationItem.rightBarButtonItems = [optionsBarButtonItem, shareBarButtonItem]
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
        articleView.onArticlePress = { [unowned self] listArticle in
            self.navigationController?.pushViewController(ArticleViewController(listArticle: listArticle), animated: true)
        }
        articleView.onImagePress = { [unowned self] index in
            guard let article = observableArticle.article else { return }
            let galleryViewController = GalleryViewController(images: article.images, currentIndex: index)
            galleryViewController.modalPresentationStyle = .overFullScreen
            self.present(galleryViewController, animated: true)
        }
        
        addSwiftUIView(articleView)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Private methods
    
    private func generateTextSizeMenu() -> UIMenu {
        let decreaseAction = UIAction(title: "Smanji", image: UIImage(named: "decrease-text"), identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off) { [weak self] _ in
            AppStorage.articleFontSize = max(AppStorage.articleFontSize - 1, 13)
            NotificationCenter.dispatch(notification: .articleFontSizeChanged)
            self?.optionsBarButtonItem.menu = self?.generateOptionsMenu()
        }
        
        let increaseAction = UIAction(title: "Povećaj", image: UIImage(named: "increase-text"), identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off) { [weak self] _ in
            AppStorage.articleFontSize = min(AppStorage.articleFontSize + 1, 20)
            NotificationCenter.dispatch(notification: .articleFontSizeChanged)
            self?.optionsBarButtonItem.menu = self?.generateOptionsMenu()
        }
        
        let statusAction = UIAction(title: String(AppStorage.articleFontSize), image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [.disabled], state: .off) { _ in }
        
        let menu = UIMenu(title: "Povećajte ili smanjite veličinu teksta u člancima", options: .displayInline,  children: [decreaseAction, statusAction, increaseAction])
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
        
        let menu = UIMenu(title: "",  children: [bookmark == nil ? bookmarkAction : unbookmarkAction , generateTextSizeMenu()])
        
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
    @State private var index = 0
    
    var onCategoryPress: (() -> Void)?
    var onTagPress: ((Tag) -> Void)?
    var fetchArticle: (() async throws -> ArticleResponse)?
    var onCommentPress: (() -> Void)?
    var onArticlePress: ((ListArticle) -> Void)?
    var onImagePress: ((Int) -> Void)?
    
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
                    .padding(.horizontal, 16)
                    Text(listArticle.title)
                        .font(Font(UIFont.Montserrat(.bold, size: 18)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                    HStack(alignment: .center, spacing: 1) {
                        Text(Date.formatToFullDate(apiDate: listArticle.publishedAt))
                            .font(Font(UIFont.Montserrat(.semibold, size: 13)))
                            .foregroundStyle(Color(UIColor.systemGray))
                        Spacer()
                        if observableArticle.article?.hasComments?.bool ?? true {
                            Button {
                                onCommentPress?()
                            } label: {
                                HStack {
                                    Image("comments")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 16, height: 20)
                                        .tint(Color(UIColor.systemGray))
                                    Text(String(listArticle.commentsCount))
                                        .font(Font(UIFont.Montserrat(.semibold, size: 13)))
                                        .foregroundStyle(Color(UIColor.systemGray))
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 16)
                    if let article = observableArticle.article, !article.images.isEmpty {
                        ZStack(alignment: .bottomLeading) {
                            PagingView(index: $index.animation(), maxIndex: article.images.count - 1) {
                                ForEach(article.images) { image in
                                    LazyImage(url: URL(string: image.styles.original)) { state in
                                        if let image = state.image {
                                            image.resizable().aspectRatio(contentMode: .fill)
                                        } else {
                                            Color.gray.opacity(0.2) // Acts as a placeholder
                                        }
                                    }
                                    .aspectRatio(4.5/3, contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width)
                                }
                            }
                            .aspectRatio(4.5/3, contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width)
                            Text("Autor: \(article.images[index].author)")
                                .font(Font(UIFont.Montserrat(.semibold, size: 13)))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(Color.black.opacity(0.7))
                                .foregroundStyle(Color.white)
                                .cornerRadius(8, corners: [.topRight])
                        }
                        .frame(width: UIScreen.main.bounds.width)
                        .padding(.top, 10)
                        .onTapGesture {
                            onImagePress?(index)
                        }
                    } else {
                        LazyImage(url: URL(string: listArticle.image.original ?? "")) { state in
                            if let image = state.image {
                                image.resizable().aspectRatio(contentMode: .fill)
                            } else {
                                Color.gray.opacity(0.2) // Acts as a placeholder
                            }
                        }
                        .aspectRatio(4.5/3, contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width)
                        .padding(.top, 10)
                    }
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.top, 18)
                }
                
                if let article = observableArticle.article {
                    let _ = print("webview height: \(webViewHeight)")
                    WebView(text: article.body().wrappedInHTML(linkColor: UIColor(hex: article.section.color_hex)), dynamicHeight: $webViewHeight)
                        .frame(height: webViewHeight)
                        .padding(.top, 8)
                        .padding(.horizontal, 16)
                    if webViewHeight > 0 {
                        Divider()
                            .overlay(Color(UIColor(hex: article.section.color_hex)))
                            .padding(.top, 10)
                        Text("TAGOVI")
                            .font(Font(UIFont.Montserrat(.extraBold, size: 13)))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 10)
                            .padding(.horizontal, 16)
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
                        .padding(.horizontal, 16)
                        if !observableArticle.relatedArticles.isEmpty {
                            Divider()
                                    .overlay(Color(UIColor(hex: article.section.color_hex)))
                                    .padding(.top, 10)
                            Text("POVEZANO")
                                .font(Font(UIFont.Montserrat(.extraBold, size: 13)))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 10)
                                .padding(.horizontal, 16)
                            ForEach(Array(observableArticle.relatedArticles.enumerated()), id: \.element) { index, relatedArticle in
                                Button {
                                    onArticlePress?(relatedArticle)
                                } label: {
                                    HStack(alignment: .center, spacing: 12) {
                                        LazyImage(url: URL(string: relatedArticle.image.original ?? "")) { state in
                                            if let image = state.image {
                                                image.resizable().aspectRatio(contentMode: .fill)
                                            } else {
                                                Color.clear
                                            }
                                        }
                                        .frame(width: 48, height: 36)
                                        .cornerRadius(8)
                                        Text(relatedArticle.title)
                                            .font(Font(UIFont.Montserrat(.semibold, size: 15)))
                                            .foregroundStyle(Color.primary)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(2)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.top, index == 0 ? 10 : 16)
                                }
                            }
                        }
                        if article.hasComments?.bool ?? true {
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
                            .padding(.horizontal, 16)
                        }
                        Spacer()
                            .frame(height: 10)
                    } else if observableArticle.listArticle != nil {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding(.top, 18)
                    }
                }
            }
            Spacer()
        }
        .refreshable {
            guard let fetchArticle else { return }
            do {
                var articleResponse = try await fetchArticle()
                articleResponse.article._images = articleResponse.article.images.sorted { $0.is_main > $1.is_main }
                self.observableArticle.article = articleResponse.article
                self.observableArticle.relatedArticles = articleResponse.related
            } catch {
                print("Error while refetching article:", error)
            }
        }
    }
}
