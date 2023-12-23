//
//  WebView.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 19. 11. 2023..
//

import SwiftUI
import WebKit

struct WebView : UIViewRepresentable {
    var text: String
    @Binding var dynamicHeight: CGFloat
    var isLoaded = false
    
    var webview: WKWebView = WKWebView()

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
            super.init()
            NotificationCenter.observe(notification: .articleFontSizeChanged) { [weak self] _ in
                let javascriptFunction = "fontSizeChanged(\(AppStorage.articleFontSize))"
                self?.parent.webview.evaluateJavaScript(javascriptFunction, completionHandler: { _, error in
                    DispatchQueue.main.async {
                        self?.parent.webview.setNeedsLayout()
                        self?.parent.webview.layoutIfNeeded()
                        self?.parent.webview.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                            DispatchQueue.main.async {
                                self?.parent.dynamicHeight = height as! CGFloat
                                self?.parent.isLoaded = true
                            }
                        })
                    }
                })
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, error) in
                DispatchQueue.main.async {
                    self.parent.dynamicHeight = height as! CGFloat
                    self.parent.isLoaded = true
                }
            })
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            guard parent.isLoaded && navigationAction.navigationType == .linkActivated else { return .allow }
            if let url = navigationAction.request.url, url.absoluteString.hasPrefix("http") {
                await MainActor.run {
                    UIApplication.shared.open(url, options: [:])
                }
                return WKNavigationActionPolicy.cancel
            } else {
                return WKNavigationActionPolicy.allow
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView  {
        webview.scrollView.bounces = false
        webview.navigationDelegate = context.coordinator
        webview.uiDelegate = context.coordinator
        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(text, baseURL: Bundle.main.bundleURL)
    }
}
