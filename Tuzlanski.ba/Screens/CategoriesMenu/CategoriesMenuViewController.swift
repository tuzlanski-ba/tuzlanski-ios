//
//  CategoriesMenuViewController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 11. 11. 2023..
//

import UIKit
import SwiftUI
import SafariServices

enum GenericLink: String {
    case about = "https://tuzlanski.ba/stranica/o-nama/3"
    case contact = "https://tuzlanski.ba/stranica/kontakt/5"
    case impressum = "https://tuzlanski.ba/stranica/impressum/2"
    case marketing = "https://tuzlanski.ba/stranica/marketing/4"
    case terms = "https://tuzlanski.ba/stranica/uslovi-koristenja/1"
    case privacy = "https://tuzlanski.ba/stranica/politika-privatnosti/10"
    case sendNews = "https://tuzlanski.ba/stranica/posalji-vijest/6"
    
    var title: String {
        switch self {
        case .about:
            return "O nama"
        case .contact:
            return "Kontakt"
        case .impressum:
            return "Impressum"
        case .marketing:
            return "Marketing"
        case .terms:
            return "Uslovi korištenja"
        case .privacy:
            return "Politika privatnosti"
        case .sendNews:
            return "Pošalji vijest"
        }
    }
    
    var url: URL {
        return URL(string: self.rawValue)!
    }
}

class MenuWithCategories: ObservableObject {
    @Published var categories: [Category] = AppStorage.categories
}

class CategoriesMenuViewController: UIViewController {
    
    private let httpClient = TuzlanskiHttpClient()
    private let menu = MenuWithCategories()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            do {
                let categories = try await httpClient.fetchCategories()
                AppStorage.categories = categories
                menu.categories = categories
            } catch {
                print("Error while fetching categories:", error)
            }
        }
    }
    
    override func loadView() {
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .tuzlanskiDarkBlue
        
        overrideUserInterfaceStyle = .dark
        
        let categoriesView = CategoriesView(menu: menu,
                                            onCategoryPressed: { [unowned self] category in
            self.dismiss(animated: true)
            NotificationCenter.dispatch(notification: .menuCategoryPressed, payload: ["category": category])
        },
                                            onGenericLinkPressed: { [unowned self] genericLink in
            present(SFSafariViewController(url: genericLink.url), animated: true)
        })
        
        addSwiftUIView(categoriesView)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

struct CategoriesView: View {
    
    @ObservedObject var menu: MenuWithCategories
    
    var onCategoryPressed: (Category) -> Void
    var onGenericLinkPressed: (GenericLink) -> Void
    
    var body: some View {
        ZStack {
            Color(UIColor.tuzlanskiDarkBlue)
                .ignoresSafeArea()
            
            GeometryReader { geo in
                ScrollView {
                    VStack {
                        Image("tuzlanski-logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 40)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 10)
                        ForEach(menu.categories) { category in
                            CategoryRowView(category: category, onCategoryPressed: onCategoryPressed)
                        }
                        genericLinkRow(.about)
                        Divider()
                        genericLinkRow(.contact)
                        Divider()
                        genericLinkRow(.impressum)
                        Divider()
                        genericLinkRow(.marketing)
                        Divider()
                        genericLinkRow(.terms)
                        Divider()
                        genericLinkRow(.privacy)
                        Divider()
                        genericLinkRow(.sendNews)
                        Spacer()
                        HStack(alignment: .center, spacing: 18, content: {
                            Spacer()
                            SocialMenuButton(socialNetwork: .facebook)
                            SocialMenuButton(socialNetwork: .instagram)
                            SocialMenuButton(socialNetwork: .youtube)
                            SocialMenuButton(socialNetwork: .x)
                            SocialMenuButton(socialNetwork: .tiktok)
                            SocialMenuButton(socialNetwork: .threads)
                            Spacer()
                        })
                    }
                    .frame(maxWidth: geo.size.width, minHeight: geo.size.height)
                }
                .padding(.top, 60)
                .ignoresSafeArea()
            }
            
            
        }
    }
    
    private func genericLinkRow(_ genericLink: GenericLink) -> some View {
        Button(action: {
            onGenericLinkPressed(genericLink)
        }, label: {
            HStack {
                Text(genericLink.title)
                    .font(Font(UIFont.Montserrat(.bold, size: 15)))
                    .foregroundStyle(Color.white)
                Spacer()
                Image("arrow-right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .tint(Color.white.opacity(0.75))
                    .frame(width: 14, height: 14, alignment: .center)
            }
        })
        .frame(minHeight: 26)
        .padding(.horizontal, 16)
    }
}

struct CategoryRowView: View {
    
    @State var category: Category
    
    var onCategoryPressed: (Category) -> Void
    
    @State private var collapsed = true
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    onCategoryPressed(category)
                }, label: {
                    Text(category.name)
                        .foregroundStyle(Color(UIColor(hex: category.color)))
                        .font(Font(UIFont.Montserrat(.bold, size: 15)))
                })
                Spacer()
                Button(action: {
                    withAnimation {
                        collapsed.toggle()
                    }
                }, label: {
                    Image("chevron-right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .tint(Color.white.opacity(0.75))
                        .frame(width: 14, height: 14, alignment: .center)
                        .rotationEffect(collapsed ? .degrees(0) : .degrees(90))
                })
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 26)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    collapsed.toggle()
                }
            }
            Divider()
            if !collapsed {
                ForEach(category.subcategories) { subcategory in
                    HStack {
                        Button(action: {
                            onCategoryPressed(subcategory)
                        }, label: {
                            Text(subcategory.name)
                                .foregroundStyle(Color.white)
                                .font(Font(UIFont.Montserrat(.bold, size: 14)))
                        })
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .frame(minHeight: 26)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onCategoryPressed(subcategory)
                    }
                    Divider()
                }
            }
        }
        
    }
}
