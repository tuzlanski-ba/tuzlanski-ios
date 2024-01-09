//
//  SocialAuthenticator.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 8. 1. 2024..
//

import Foundation
import AuthenticationServices

enum SocialAuthType: CaseIterable {
    case google
    case facebook
    case apple
    
    var name: String {
        switch self {
        case .google:
            return "google"
        case .facebook:
            return "facebook"
        case .apple:
            return "apple"
        }
    }
    
    var url: URL {
        switch self {
        case .google:
            return URL(string: "https://dev.tuzlanski.ba/auth/social-auth/redirect/google/api")!
        case .facebook:
            return URL(string: "https://dev.tuzlanski.ba/auth/social-auth/redirect/facebook/api")!
        case .apple:
            return URL(string: "https://dev.tuzlanski.ba/auth/social-auth/redirect/apple/api")!
        }
    }
}

enum SocialAuthenticatorError: Error {
    case internalError
    case authError
}

class SocialAuthenticator: NSObject, ASWebAuthenticationPresentationContextProviding {
    
    private var session: ASWebAuthenticationSession?
    
    @MainActor
    func authenticate(type: SocialAuthType) async throws -> LoginResponse {
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(url: type.url, callbackURLScheme: "tuzlanski-auth") { (url, error) in
                if error != nil {
                    continuation.resume(throwing: SocialAuthenticatorError.internalError)
                    return
                }
                
                guard let components = url?.components else {
                    continuation.resume(throwing: SocialAuthenticatorError.internalError)
                    return
                }
                
                guard let b64Data = components.queryItems?["data"]?.data(using: .utf8) else {
                    continuation.resume(throwing: SocialAuthenticatorError.authError)
                    return
                }
                
                guard let data = Data(base64Encoded: b64Data) else {
                    continuation.resume(throwing: SocialAuthenticatorError.authError)
                    return
                }
                
                guard let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) else {
                    continuation.resume(throwing: SocialAuthenticatorError.authError)
                    return
                }
                
                continuation.resume(with: .success(loginResponse))
            }
            self.session = session
            
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = true
            session.start()
        }
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .last { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}

// MARK: - Extensions

fileprivate extension URL {
    var components: URLComponents? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)
    }
}

fileprivate extension Array where Iterator.Element == URLQueryItem {
    subscript(_ key: String) -> String? {
        return first(where: { $0.name == key })?.value
    }
}
