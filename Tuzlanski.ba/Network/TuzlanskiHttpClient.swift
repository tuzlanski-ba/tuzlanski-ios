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
    let host = "https://tuzlanski.ba/api/v1/"
    
    private let authToken = "6e49696f0e4fd2002bc9379118da031be581cb48"
    
    // MARK: - API
    
    func fetchCategories() async throws -> [Category] {
        let response: [String: MenuItem] = try await fetchRawCategories()
        
        let categories = response.values.map { menuItem in
            return Category(id: menuItem.id, slug: menuItem.slug_short, name: menuItem.name, color: menuItem.color ?? "", subcategories: menuItem.childs?.map({ childMenuItem in
                return Category(id: childMenuItem.id, slug: childMenuItem.slug_short, name: childMenuItem.name, color: childMenuItem.color_hex ?? "", subcategories: [])
            }) ?? [])
        }.sorted { $0.id < $1.id }
        
        return categories
    }
    
    func fetchRawCategories() async throws -> [String: MenuItem] {
        guard let url = URL(string: host + "menu") else { throw TuzlanskiHttpClientError.invalidURL }
        
        let request = createRequest(url: url)
        let response: [String: MenuItem] = try await execute(request: request)
        
        return response
    }
    
    func getHomeArticles() async throws -> IndexResponse {
        guard let url = URL(string: host + "index") else { throw TuzlanskiHttpClientError.invalidURL }
        
        let request = createRequest(url: url)
        let dataResponse: DataResponse<IndexResponse> = try await execute(request: request)
        
        return dataResponse.data
    }
    
    func getLatestArticles(page: Int = 1, sectionID: Int64? = nil, limit: Int = TuzlanskiHttpClient.pageLimit) async throws -> [ListArticle] {
        guard var url = URL(string: host + "articles/latest") else { throw TuzlanskiHttpClientError.invalidURL }
        url.appendQueryItem(name: "limit", value: "\(limit)")
        url.appendQueryItem(name: "page", value: String(page))
        if let sectionID {
            url.appendQueryItem(name: "section_id", value: String(sectionID))
        }
        
        let request = createRequest(url: url)
        let latestArticlesResponse: LatestArticleResponse = try await execute(request: request)
        
        return latestArticlesResponse.articles.data
    }
    
    func getLatestArticles(page: Int = 1, tagSlug: String) async throws -> [ListArticle] {
        guard var url = URL(string: host + "articles/tags/" + tagSlug) else { throw TuzlanskiHttpClientError.invalidURL }
        url.appendQueryItem(name: "limit", value: "\(Self.pageLimit)")
        url.appendQueryItem(name: "page", value: String(page))
        
        let request = createRequest(url: url)
        let latestArticlesResponse: LatestArticleResponse = try await execute(request: request)
        
        return latestArticlesResponse.articles.data
    }
    
    func getMostReadsArticles(page: Int = 1, limit: Int = TuzlanskiHttpClient.pageLimit) async throws -> [ListArticle] {
        guard var url = URL(string: host + "articles/most-reads") else { throw TuzlanskiHttpClientError.invalidURL }
        url.appendQueryItem(name: "limit", value: "\(limit)")
        url.appendQueryItem(name: "page", value: String(page))
        
        let request = createRequest(url: url)
        let latestArticlesResponse: LatestArticleResponse = try await execute(request: request)
        
        return latestArticlesResponse.articles.data
    }
    
    func searchArticles(query: String, page: Int = 1) async throws -> [ListArticle] {
        guard var url = URL(string: host + "search") else { throw TuzlanskiHttpClientError.invalidURL }
        url.appendQueryItem(name: "keywords", value: query)
        url.appendQueryItem(name: "limit", value: "\(Self.pageLimit)")
        url.appendQueryItem(name: "page", value: String(page))
        
        let request = createRequest(url: url)
        let latestArticlesResponse: LatestArticleResponse = try await execute(request: request)
        
        return latestArticlesResponse.articles.data
    }
    
    func getArticle(apiURL: String) async throws -> ArticleResponse {
        guard let url = URL(string: apiURL) else { throw TuzlanskiHttpClientError.invalidURL }
        
        let request = createRequest(url: url)
        let articleResponse: ArticleResponse = try await execute(request: request)
        
        return articleResponse
    }
    
    func login(email: String, password: String) async throws -> LoginResponse {
        guard let url = URL(string: host + "auth/login") else { throw TuzlanskiHttpClientError.invalidURL }
        
        var request = createRequest(url: url)
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
            guard let failLoginResponse = try? JSONDecoder().decode(MessageResponse.self, from: data) else { throw error }
            throw TuzlanskiHttpClientError.messageError(failLoginResponse.message)
        }
    }
    
    func logout() async throws {
        guard let url = URL(string: host + "auth/logout") else { throw TuzlanskiHttpClientError.invalidURL }
        
        var request = createRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(getAuthHeader(), forHTTPHeaderField: "Authorization")
        
        let _: MessageResponse = try await execute(request: request)
    }
    
    func requestAccountDeletion() async throws -> MessageResponse {
        guard let url = URL(string: host + "account/request-for-deletion") else { throw TuzlanskiHttpClientError.invalidURL }
        
        var request = createRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(getAuthHeader(), forHTTPHeaderField: "Authorization")
        
        let response: MessageResponse = try await execute(request: request)
        
        return response
    }
    
    func resetPassword(email: String) async throws {
        guard let url = URL(string: host + "password/email") else { throw TuzlanskiHttpClientError.invalidURL }
        
        var request = createRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = ["email": email].percentEncoded()
        
        let response: MessageResponse = try await execute(request: request)
        
        if response.message != "Poslan vam je e-mail za promjenu šifre!" {
            throw TuzlanskiHttpClientError.messageError("Došlo je do greške prilikom resetovanja šifre. Molimo pokušajte ponovo.")
        }
    }
    
    func register(username: String, email: String, password: String, passwordConfirm: String) async throws -> Result<LoginResponse, InputErrorResponse> {
        guard let url = URL(string: host + "auth/register") else { throw TuzlanskiHttpClientError.invalidURL }
        
        var request = createRequest(url: url)
        request.httpMethod = "POST"
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
        
        var request = createRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(getAuthHeader(), forHTTPHeaderField: "Authorization")
        
        let _: User = try await execute(request: request)
    }
    
    func getLatestComments(page: Int = 1, articleID: Int64) async throws -> [Comment] {
        guard var url = URL(string: host + "comments") else { throw TuzlanskiHttpClientError.invalidURL }
        url.appendQueryItem(name: "limit", value: "\(Self.pageLimit)")
        url.appendQueryItem(name: "page", value: String(page))
        url.appendQueryItem(name: "article_id", value: String(articleID))
        url.appendQueryItem(name: "sort_column", value: String("upvotes"))
        
        let request = createRequest(url: url)
        let dataResponse: DataResponse<[Comment]> = try await execute(request: request)
        
        return dataResponse.data
    }
    
    func upvote(comment: Comment) async throws -> Comment {
        guard let url = URL(string: host + "comments/upvote/\(comment.id)") else { throw TuzlanskiHttpClientError.invalidURL }
        
        var request = createRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(getAuthHeader(), forHTTPHeaderField: "Authorization")
        
        let comment: Comment = try await execute(request: request)
        
        return comment
    }
    
    func downvote(comment: Comment) async throws -> Comment {
        guard let url = URL(string: host + "comments/downvote/\(comment.id)") else { throw TuzlanskiHttpClientError.invalidURL }
        
        var request = createRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(getAuthHeader(), forHTTPHeaderField: "Authorization")
        
        let comment: Comment = try await execute(request: request)
        
        return comment
    }
    
    func report(comment: Comment, reason type: CommentReportType) async throws -> CommentReportResponse {
        guard let url = URL(string: host + "comments/report/\(comment.id)") else { throw TuzlanskiHttpClientError.invalidURL }
        
        var request = createRequest(url: url)
        request.httpMethod = "POST"
        let userAuthHeader = getAuthHeader()
        if !userAuthHeader.isEmpty {
            request.setValue(userAuthHeader, forHTTPHeaderField: "Authorization")
        }
        request.httpBody = ["type": String(type.rawValue)].percentEncoded()
        
        let response: CommentReportResponse = try await execute(request: request)
        
        return response
    }
    
    func post(comment: String, article: Article, replyToComment: Comment? = nil) async throws -> Comment {
        guard let url = URL(string: host + "comments") else { throw TuzlanskiHttpClientError.invalidURL }
        
        var request = createRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(getAuthHeader(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var body = ["content": comment, "article_id": String(article.id)]
        if let replyToComment {
            body["thread_id"] = String(replyToComment.thread_id == 0 ? replyToComment.id : replyToComment.thread_id)
        }
        
        request.httpBody = body.percentEncoded()
        
        var data = Data()
        do {
            let response = try await URLSession.shared.data(for: request)
            data = try mapResponse(response: response, allowAllStatusCodes: true)
            
            Log.api.info("Fetched data: \(String(data: data, encoding: .utf8) ?? "null")")
            
            let comment = try JSONDecoder().decode(Comment.self, from: data)
            return comment
        } catch {
            guard let errorResponse = try? JSONDecoder().decode(MessageResponse.self, from: data) else { throw error }
            throw TuzlanskiHttpClientError.messageError(errorResponse.message)
        }
    }
    
    func getUserComments() async throws -> [UserCommentsResponse.UserComment] {
        guard let url = URL(string: host + "account/comments") else { throw TuzlanskiHttpClientError.invalidURL }
        
        var request = createRequest(url: url)
        request.setValue(getAuthHeader(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let response: UserCommentsResponse = try await execute(request: request)
        
        return response.comments
    }
    
    func changePassword(password: String, passwordConfirmation: String) async throws -> Result<PasswordChangeResponse, InputErrorResponse> {
        guard let url = URL(string: host + "account/password") else { throw TuzlanskiHttpClientError.invalidURL }
        
        var request = createRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(getAuthHeader(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = ["password": password, "password_confirmation": passwordConfirmation].percentEncoded()
        
        var data = Data()
        do {
            let response = try await URLSession.shared.data(for: request)
            data = try mapResponse(response: response, allowAllStatusCodes: true)
            
            Log.api.info("Fetched data: \(String(data: data, encoding: .utf8) ?? "null")")
            
            let passwordChangeResponse = try JSONDecoder().decode(PasswordChangeResponse.self, from: data)
            return .success(passwordChangeResponse)
        } catch {
            guard let errorResponse = try? JSONDecoder().decode(InputErrorResponse.self, from: data) else { throw error }
            return .failure(errorResponse)
        }
    }
    
    func fetchUserInfo() async throws -> User {
        guard let url = URL(string: host + "account/profile") else { throw TuzlanskiHttpClientError.invalidURL }
        
        var request = createRequest(url: url)
        request.setValue(getAuthHeader(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let response: User = try await execute(request: request)
        
        return response
    }
    
    func pollVote(id: Int64, voteID: Int) async throws -> Poll {
        guard let url = URL(string: host + "polls/\(id)/vote/\(voteID)") else { throw TuzlanskiHttpClientError.invalidURL }
        
        var request = createRequest(url: url)
        request.httpMethod = "POST"
        
        let response: Poll = try await execute(request: request)
        
        return response
    }
    
    // MARK: - Private methods
    
    private func createRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue(authToken, forHTTPHeaderField: "ApiToken")
        
        return request
    }
    
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
        let token = KeychainSwift().get("user_token")
        if token?.isEmpty ?? true {
            return ""
        }
        
        return "Bearer \(token ?? "no-token")"
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

