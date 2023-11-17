//
//  TuzlanskiHttpClient.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 11. 11. 2023..
//

import Foundation

enum TuzlanskiHttpClientError: Error {
    case invalidURL
    case httpError
}

struct DataResponse<T : Codable>: Codable {
    var data: T
}

class TuzlanskiHttpClient {
    
    // MARK: - Properties
    
    private let host = "https://dev.tuzlanski.ba/api/v1/"
    
    // TODO: Delete this when public system is released
    private let auth = "Basic \(Data("tuzlanski:2023".utf8).base64EncodedString())"
    
    // MARK: - API
    
    func fetchCategories() async throws -> [Category] {
        guard let url = URL(string: host + "menu") else { throw TuzlanskiHttpClientError.invalidURL }
        
        var request = URLRequest(url: url)
        request.setValue(auth, forHTTPHeaderField: "Authorization")
        
        let response: [String: MenuItem] = try await execute(request: request)
        
        let categories = response.values.map { menuItem in
            return Category(id: menuItem.id, slug: menuItem.slug_short, name: menuItem.name, color: menuItem.color ?? "", subcategories: menuItem.childs?.map({ childMenuItem in
                return Category(id: childMenuItem.id, slug: childMenuItem.slug_short, name: childMenuItem.name, color: childMenuItem.color_hex ?? "", subcategories: [])
            }) ?? [])
        }.sorted { $0.id < $1.id }
        
        return categories
    }
    
    func getHomeArticles() async throws -> IndexResponse {
        guard let url = URL(string: host + "index") else { throw TuzlanskiHttpClientError.invalidURL }
        
        var request = URLRequest(url: url)
        request.setValue(auth, forHTTPHeaderField: "Authorization")
        
        let dataResponse: DataResponse<IndexResponse> = try await execute(request: request)
        
        return dataResponse.data
    }
    
    // MARK: - Private methods
    
    private func execute<T: Codable>(request: URLRequest) async throws -> T {
        let response = try await URLSession.shared.data(for: request)
        let data = try mapResponse(response: response)
        
        //Log.api.info("Fetched data: \(String(data: data, encoding: .utf8) ?? "null")")
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func mapResponse(response: (data: Data, response: URLResponse)) throws -> Data {
        guard let httpResponse = response.response as? HTTPURLResponse else {
            return response.data
        }
        
        if 200...299 ~= httpResponse.statusCode {
            return response.data
        }
        
        Log.api.error("HTTP response invalid status code: \(httpResponse.statusCode) for url: \(httpResponse.url?.absoluteString ?? "")")
        
        throw TuzlanskiHttpClientError.httpError
    }
}
