//
//  TuzlanskiHttpClient.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 11. 11. 2023..
//

import Foundation
import KeychainSwift

enum TuzlanskiHttpClientError: Error {
    case invalidURL
    case httpError
    case messageError(String)
}

struct DataResponse<T : Codable>: Codable {
    var data: T
}

class TuzlanskiHttpClient {
    
    // MARK: - Properties
   
    static let pageLimit = 25
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
    
    func getLatestArticles(page: Int = 1, sectionID: Int64? = nil) async throws -> [ListArticle] {
        guard var url = URL(string: host + "articles/latest") else { throw TuzlanskiHttpClientError.invalidURL }
        url.appendQueryItem(name: "limit", value: "\(Self.pageLimit)")
        url.appendQueryItem(name: "page", value: String(page))
        if let sectionID {
            url.appendQueryItem(name: "section_id", value: String(sectionID))
        }
        
        var request = URLRequest(url: url)
        request.setValue(auth, forHTTPHeaderField: "Authorization")
        
        let latestArticlesResponse: LatestArticleResponse = try await execute(request: request)
        
        return latestArticlesResponse.articles.data
    }
    
    func getLatestArticles(page: Int = 1, tagSlug: String) async throws -> [ListArticle] {
        guard var url = URL(string: host + "articles/tags/" + tagSlug) else { throw TuzlanskiHttpClientError.invalidURL }
        url.appendQueryItem(name: "limit", value: "\(Self.pageLimit)")
        url.appendQueryItem(name: "page", value: String(page))
        
        var request = URLRequest(url: url)
        request.setValue(auth, forHTTPHeaderField: "Authorization")
        
        let latestArticlesResponse: LatestArticleResponse = try await execute(request: request)
        
        return latestArticlesResponse.articles.data
    }
    
    func getArticle(listArticle: ListArticle) async throws -> Article {
        guard let url = URL(string: listArticle.apiURL) else { throw TuzlanskiHttpClientError.invalidURL }
        
        var request = URLRequest(url: url)
        request.setValue(auth, forHTTPHeaderField: "Authorization")
        
        let articleResponse: ArticleResponse = try await execute(request: request)
        
        return articleResponse.article
    }
    
    func login(email: String, password: String) async throws -> LoginResponse {
        guard let url = URL(string: host + "auth/login") else { throw TuzlanskiHttpClientError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = ["email": email, "password": password].percentEncoded()
        
        var data = Data()
        do {
            let response = try await URLSession.shared.data(for: request)
            data = try mapResponse(response: response, allowAllStatusCodes: true)
            
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            return loginResponse
        } catch {
            guard let failLoginResponse = try? JSONDecoder().decode(FailLoginResponse.self, from: data) else { throw error }
            throw TuzlanskiHttpClientError.messageError(failLoginResponse.message)
        }
    }
    
    func logout() async throws {
        guard let url = URL(string: host + "auth/logout") else { throw TuzlanskiHttpClientError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(getAuthHeader(), forHTTPHeaderField: "Authorization")
        
        let _: FailLoginResponse = try await execute(request: request)
    }
    
    func resetPassword(email: String) async throws {
        guard let url = URL(string: host + "password/email") else { throw TuzlanskiHttpClientError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = ["email": email].percentEncoded()
        
        let response: FailLoginResponse = try await execute(request: request)
        
        if response.message != "Poslan vam je e-mail za promjenu šifre!" {
            throw TuzlanskiHttpClientError.messageError("Došlo je do greške prilikom resetovanja šifre. Molimo pokušajte ponovo.")
        }
    }
    
    func register(username: String, email: String, password: String, passwordConfirm: String) async throws -> Result<LoginResponse, InputErrorResponse> {
        guard let url = URL(string: host + "auth/register") else { throw TuzlanskiHttpClientError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(auth, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = ["name": username, "email": email, "password": password, "password_confirmation": passwordConfirm, "tos": "1"].percentEncoded()
        
        var data = Data()
        do {
            let response = try await URLSession.shared.data(for: request)
            data = try mapResponse(response: response, allowAllStatusCodes: true)
            
            Log.api.info("Fetched data: \(String(data: data, encoding: .utf8) ?? "null")")
            
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            return .success(loginResponse)
        } catch {
            guard let errorResponse = try? JSONDecoder().decode(InputErrorResponse.self, from: data) else { throw error }
            return .failure(errorResponse)
        }
    }
    
    func resendVerificationEmail() async throws {
        guard let url = URL(string: host + "email/resend") else { throw TuzlanskiHttpClientError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(getAuthHeader(), forHTTPHeaderField: "Authorization")
        
        let _: User = try await execute(request: request)
    }
    
    // MARK: - Private methods
    
    private func execute<T: Codable>(request: URLRequest) async throws -> T {
        let response = try await URLSession.shared.data(for: request)
        let data = try mapResponse(response: response)
        
        Log.api.info("Fetched data: \(String(data: data, encoding: .utf8) ?? "null")")
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func mapResponse(response: (data: Data, response: URLResponse), allowAllStatusCodes: Bool = false) throws -> Data {
        guard let httpResponse = response.response as? HTTPURLResponse else {
            return response.data
        }
        
        if 200...299 ~= httpResponse.statusCode || allowAllStatusCodes {
            return response.data
        }
        
        Log.api.error("HTTP response invalid status code: \(httpResponse.statusCode) for url: \(httpResponse.url?.absoluteString ?? "")")
        
        throw TuzlanskiHttpClientError.httpError
    }
    
    private func getAuthHeader() -> String {
        return "Bearer \(KeychainSwift().get("user_token") ?? "no-token")"
    }
}

// MARK: - Extensions

fileprivate extension Dictionary {
    
    func percentEncoded() -> Data? {
        map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

fileprivate extension CharacterSet {
    
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed: CharacterSet = .urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

