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

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: WebView
        var didFinishLoad = false
        var didFinishNavigation = false

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
            guard !didFinishNavigation else { return }
            didFinishNavigation = true
            webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
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
                    if (url.absoluteString.contains("tuzlanski.ba")) {
                        let userActivity =  NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
                        userActivity.webpageURL = url
                        _ = UIApplication.shared.delegate?.application?(UIApplication.shared, continue: userActivity, restorationHandler: { _ in })
                    } else {
                        UIApplication.shared.open(url, options: [:])
                    }
                }
                return WKNavigationActionPolicy.cancel
            } else {
                return WKNavigationActionPolicy.allow
            }
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "logHandler" {
                print("\(message.body)")
            } else if message.name == "loadEvent" {
                guard !didFinishLoad else { return }
                didFinishLoad = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.parent.webview.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (heightAny, error) in
                        DispatchQueue.main.async {
                            let height = heightAny as! CGFloat
                            print("loadEvent height \(height)")
                            guard height > self.parent.dynamicHeight else { return }
                            self.parent.dynamicHeight = height
                            self.parent.isLoaded = true
                        }
                    })
                }
            } else if message.name == "widgetHeight" {
                guard let height = (message.body as? NSNumber)?.doubleValue else { return }
                guard height > self.parent.dynamicHeight else { return }
                DispatchQueue.main.async {
                    print("widgetHeight height \(height)")
                    self.parent.dynamicHeight = height
                    self.parent.isLoaded = true
                }
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
        
        let overrideConsole = """
            function log(emoji, type, args) {
              window.webkit.messageHandlers.logHandler.postMessage(
                `${emoji} JS ${type}: ${Object.values(args)
                  .map(v => typeof(v) === "undefined" ? "undefined" : typeof(v) === "object" ? JSON.stringify(v) : v.toString())
                  .map(v => v.substring(0, 3000)) // Limit msg to 3000 chars
                  .join(", ")}`
              )
            }

            let originalLog = console.log
            let originalWarn = console.warn
            let originalError = console.error
            let originalDebug = console.debug

            console.log = function() { log("📗", "log", arguments); originalLog.apply(null, arguments) }
            console.warn = function() { log("📙", "warning", arguments); originalWarn.apply(null, arguments) }
            console.error = function() { log("📕", "error", arguments); originalError.apply(null, arguments) }
            console.debug = function() { log("📘", "debug", arguments); originalDebug.apply(null, arguments) }

            window.addEventListener("error", function(e) {
               log("💥", "Uncaught", [`${e.message} at ${e.filename}:${e.lineno}:${e.colno}`])
            })
        """
        let captureLogScript = WKUserScript(source: overrideConsole, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        webview.configuration.userContentController.addUserScript(captureLogScript)
        webview.configuration.userContentController.add(context.coordinator, name: "logHandler")

        let script = """
        window.addEventListener('load', function () {
            window.webkit.messageHandlers.loadEvent.postMessage('loaded')
        
            twttr.events.bind(
              'rendered',
              function (event) {
                window.webkit.messageHandlers.widgetHeight.postMessage(document.body.scrollHeight);
                console.log("console widget height:", document.body.scrollHeight);
              }
            );
        ;})
        """
        let wkuScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webview.configuration.userContentController.addUserScript(wkuScript)
        webview.configuration.userContentController.add(context.coordinator, contentWorld: .page, name: "loadEvent")
        webview.configuration.userContentController.add(context.coordinator, contentWorld: .page, name: "widgetHeight")
        
        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(text, baseURL: Bundle.main.bundleURL)
    }
}
