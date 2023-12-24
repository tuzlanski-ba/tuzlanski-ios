//
//  CategoriesMenuViewController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 11. 11. 2023..
//

import UIKit
import SwiftUI

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
        view.backgroundColor = .primaryBackground
        
        overrideUserInterfaceStyle = .dark
        
        addSwiftUIView(CategoriesView(menu: menu, onCategoryPressed: { category in
            NotificationCenter.dispatch(notification: .menuCategoryPressed, payload: ["category": category])
        }))
    }
}

struct CategoriesView: View {
    
    @ObservedObject var menu: MenuWithCategories
    
    var onCategoryPressed: (Category) -> Void
    
    var body: some View {
        ZStack {
            Color(UIColor.primaryBackground)
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
                        genericLinkRow(title: "O nama")
                        Divider()
                        genericLinkRow(title: "Impressum")
                        Divider()
                        genericLinkRow(title: "Marketing")
                        Divider()
                        genericLinkRow(title: "Uslovi korištenja")
                        Spacer()
                        HStack(alignment: .center, spacing: 18, content: {
                            SocialMenuButton(socialNetwork: .facebook)
                            SocialMenuButton(socialNetwork: .instagram)
                            SocialMenuButton(socialNetwork: .youtube)
                            SocialMenuButton(socialNetwork: .x)
                            SocialMenuButton(socialNetwork: .linkedin)
                            Spacer()
                        })
                        .padding(.horizontal, 16)
                    }
                    .frame(minHeight: geo.size.height)
                }
                .padding(.top, 60)
                .ignoresSafeArea()
            }
            
            
        }
    }
    
    private func genericLinkRow(title: String) -> some View {
        Button(action: {}, label: {
            HStack {
                Text(title)
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
                    Divider()
                }
            }
        }
        
    }
}
