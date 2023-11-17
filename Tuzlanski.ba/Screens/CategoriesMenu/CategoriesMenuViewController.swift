//
//  CategoriesMenuViewController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 11. 11. 2023..
//

import UIKit
import SwiftUI

class MenuWithCategories: ObservableObject {
    @Published var categories: [Category] = []
}

class CategoriesMenuViewController: UIViewController {
    
    private let httpClient = TuzlanskiHttpClient()
    private let menu = MenuWithCategories()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                let categories = try await httpClient.fetchCategories()
                menu.categories = categories
            } catch {
                print(error)
            }
        }
    }
    
    override func loadView() {
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .primaryBackground
        
        let vc = UIHostingController(rootView: CategoriesView(menu: menu, onCategoryPressed: { category in
            NotificationCenter.dispatch(notification: .menuCategoryPressed, payload: ["category": category])
        }))
        let swiftuiView = vc.view!
        swiftuiView.translatesAutoresizingMaskIntoConstraints = false
        addChild(vc)
        view.addSubview(swiftuiView)
        swiftuiView.pin(to: view)
        vc.didMove(toParent: self)
    }
}

struct CategoriesView: View {
    
    @ObservedObject var menu: MenuWithCategories
    
    var onCategoryPressed: (Category) -> Void
    
    var body: some View {
        ZStack {
            Color(UIColor.primaryBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    ForEach($menu.categories) { $category in
                        VStack {
                            HStack {
                                Button(action: {
                                    onCategoryPressed(category)
                                }, label: {
                                    Text(category.name)
                                        .foregroundStyle(Color(UIColor(hex: category.color)))
                                        .font(Font(UIFont.Montserrat(.bold, size: 20)))
                                })
                                Spacer()
                            }
                            ForEach(category.subcategories) { subcategory in
                                HStack {
                                    Button(action: {
                                        onCategoryPressed(subcategory)
                                    }, label: {
                                        Text(subcategory.name)
                                            .foregroundStyle(Color.white)
                                            .font(Font(UIFont.Montserrat(.semibold, size: 16)))
                                    })
                                    Spacer()
                                }
                                .padding(.vertical, 1)
                            }
                        }
                        .padding(.vertical, 3)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
