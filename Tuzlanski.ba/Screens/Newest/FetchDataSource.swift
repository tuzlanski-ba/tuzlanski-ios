//
//  FetchDataSource.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 25. 11. 2023..
//

import Foundation

protocol FetchDataSource {
    func fetch(page: Int) async throws -> [ListArticle]
    
    var name: String? { get }
}

struct LatestFetchDataSource: FetchDataSource {
    
    private let httpClient = TuzlanskiHttpClient()
    
    var name: String? = nil
    
    func fetch(page: Int) async throws -> [ListArticle] {
        return try await httpClient.getLatestArticles(page: page)
    }
}

struct CategoryFetchDataSource: FetchDataSource {
    
    private let httpClient = TuzlanskiHttpClient()
    
    let category: Category
    
    var name: String? {
        return category.name
    }
    
    func fetch(page: Int) async throws -> [ListArticle] {
        return try await httpClient.getLatestArticles(page: page, sectionID: category.id)
    }
}

struct TagFetchDataSource: FetchDataSource {
    
    private let httpClient = TuzlanskiHttpClient()
    
    let tag: Tag
    
    var name: String? {
        return tag.name.uppercased()
    }
    
    func fetch(page: Int) async throws -> [ListArticle] {
        return try await httpClient.getLatestArticles(page: page, tagSlug: tag.slug)
    }
}

struct MostReadsFetchDataSource: FetchDataSource {
    
    private let httpClient = TuzlanskiHttpClient()
    
    var name: String? = nil
    
    func fetch(page: Int) async throws -> [ListArticle] {
        return try await httpClient.getMostReadsArticles(page: page)
    }
}
