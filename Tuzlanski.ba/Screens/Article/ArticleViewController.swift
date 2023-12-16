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
    @Published var listArticle: ListArticle
    @Published var article: Article?
    
    internal init(listArticle: ListArticle, article: Article? = nil) {
        self.listArticle = listArticle
        self.article = article
    }
}

class ArticleViewController: UIViewController {
    
    // MARK: - Properties
    
    private var observableArticle: ObservableArticle
    private let httpClient = TuzlanskiHttpClient()
    
    // MARK: - Lifecycle
    
    init(listArticle: ListArticle) {
        self.observableArticle = ObservableArticle(listArticle: listArticle, article: nil)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                let article = try await httpClient.getArticle(listArticle: observableArticle.listArticle)
                observableArticle.article = article
            } catch {
                print(error)
            }
        }
        
        (navigationController as? SideNavigationController)?.addLogoToCurrentViewController()
        
        var articleView = ArticleView(observableArticle: observableArticle)
        articleView.onCategoryPress = { [unowned self] in
            let category = Category(id: observableArticle.listArticle.sectionID, slug: observableArticle.listArticle.section.slug_short, name: observableArticle.listArticle.section.name)
            self.navigationController?.pushViewController(LatestViewController(fetchDataSource: CategoryFetchDataSource(category: category)), animated: true)
        }
        articleView.onTagPress = { [unowned self] tag in
            self.navigationController?.pushViewController(LatestViewController(fetchDataSource: TagFetchDataSource(tag: tag)), animated: true)
        }
        articleView.fetchArticle = { [unowned self] in
            return try await httpClient.getArticle(listArticle: observableArticle.listArticle)
        }
        
        addSwiftUIView(articleView)
    }
    
    override func loadView() {
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .primaryBackground
    }
}

struct ArticleView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var observableArticle: ObservableArticle
    
    @State private var webViewHeight: CGFloat = .zero
    
    var onCategoryPress: (() -> Void)?
    var onTagPress: ((Tag) -> Void)?
    var fetchArticle: (() async throws -> Article)?
    
    var body: some View {
        ScrollView {
            Spacer()
                .frame(height: 10)
            VStack(spacing: 4) {
                Button {
                    onCategoryPress?()
                } label: {
                    Text((observableArticle.listArticle.preTitle ?? observableArticle.listArticle.section.path.replacingOccurrences(of: ">", with: "/")).uppercased())
                        .font(Font(UIFont.Montserrat(.bold, size: 13)))
                        .foregroundStyle(Color(UIColor(hex: observableArticle.listArticle.section.color_hex)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Text(observableArticle.listArticle.title)
                    .font(Font(UIFont.Montserrat(.bold, size: 18)))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(Date.formatToFullDate(apiDate: observableArticle.listArticle.publishedAt))
                    .font(Font(UIFont.Montserrat(.semibold, size: 13)))
                    .foregroundStyle(Color(UIColor.systemGray2))
                    .frame(maxWidth: .infinity, alignment: .leading)
                LazyImage(url: URL(string: observableArticle.listArticle.image.original)) { state in
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
                if let article = observableArticle.article {
                    WebView(text: article.longText.wrappedInHTML, dynamicHeight: $webViewHeight)
                        .frame(height: webViewHeight)
                        .padding(.top, 8)
                    if webViewHeight > 0 {
                    Divider()
                            .overlay(Color(UIColor(hex: article.section.color_hex)))
                            .padding(.top, 6)
                        Text("TAGOVI")
                            .font(Font(UIFont.Montserrat(.extraBold, size: 13)))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 6)
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
                            .padding(.top, 6)
                        Button(action: {}) {
                            Text("KOMENTARI (0)")
                                .font(Font(UIFont.Montserrat(.bold, size: 14)))
                                .tint(Color.white)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .frame(height: 40)
                        .background(Color(UIColor(hex: article.section.color_hex)))
                        .cornerRadius(6)
                        .padding(.top, 6)
                        Spacer()
                            .frame(height: 10)
                    } else {
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
