//
//  String+HTML.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 18. 11. 2023..
//

import UIKit

fileprivate func fontDataURL(name: String, ext: String = "ttf") -> String? {
    guard let url = Bundle.main.url(forResource: name, withExtension: ext),
          let data = try? Data(contentsOf: url) else { return nil }
    return "data:font/ttf;base64,\(data.base64EncodedString())"
}

extension String {
    
    func wrappedInHTML(linkColor: UIColor = .tintColor, showPollResults: Bool) -> String {
        
        let montserrat400 = fontDataURL(name: "Montserrat-Medium") ?? ""
        let montserrat600 = fontDataURL(name: "Montserrat-SemiBold") ?? ""
        let montserrat700 = fontDataURL(name: "Montserrat-Bold") ?? ""
        
        var processedText = self.replacingOccurrences(of: "</figcaption>\r\n</figure>", with: "</figcaption></figure>")
        processedText = processedText.replacingOccurrences(of: "<p></p>", with: "")
        processedText.removingRegexMatches(pattern: "\\[gallery.*\\]")
        
        processedText = processedText.replacingOccurrences(of: "src=\"https://tuzlanski.ba/assets/img/lazy.png\"", with: "")
        processedText = processedText.replacingOccurrences(of: "data-src=", with: "src=")
        
        let html = """
            <!doctype html>
            <html lang="ba">
            <head>
                <meta charset="utf-8">
                <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, shrink-to-fit=no'>
                <script>window.twttr = (function(d, s, id) {
                  var js, fjs = d.getElementsByTagName(s)[0],
                    t = window.twttr || {};
                  if (d.getElementById(id)) return t;
                  js = d.createElement(s);
                  js.id = id;
                  js.src = "https://platform.twitter.com/widgets.js";
                  fjs.parentNode.insertBefore(js, fjs);

                  t._e = [];
                  t.ready = function(f) {
                    t._e.push(f);
                  };

                  return t;
                }(document, "script", "twitter-wjs"));</script>
                <style type="text/css">
                    @font-face { font-family: 'Montserrat'; url('\(montserrat400)') format('truetype'); font-weight: 400; }
                    @font-face { font-family: 'Montserrat'; src: url('\(montserrat600)') format('truetype'); font-weight: 600; }
                    @font-face { font-family: 'Montserrat'; src: url('\(montserrat700)') format('truetype'); font-weight: 700; }
            
                    :root {
                        font-size:\(AppStorage.articleFontSize)px;
                    }
            
                    body {
                        background: \(UIColor.screenBackground.hex);
                        font-family: 'Montserrat';
                        color: \(UIColor.label.hex);
                        -webkit-text-size-adjust: none;
                        margin: 0;
                        padding: 0;
                        font-size: 1rem;
                    }
            
                    h1 {
                      font-size: 2rem;
                    }

                    h2 {
                      font-size: 1.5rem;
                    }

                    h3 {
                      font-size: 1.25rem;
                    }

                    h4 {
                      font-size: 1.125rem;
                    }

                    h5 {
                      font-size: 1rem;
                    }

                    h6 {
                      font-size: 0.875rem;
                    }
            
                    h1, h2, h3, h4, h5, h6 {
                        color: \(UIColor.label.hex);
                    }
            
                    a {
                        color: \(linkColor.hex) !important;
                        text-decoration: none !important;
                    }
            
                    p {
                        padding: 0;
                        margin: 0;
                        padding-top: 8px;
                    }
            
                    strong.firstParagraph p {
                        padding-bottom: 8px;
                    }
            
                    p + p, strong.firstParagraph + p {
                        padding: 8px 0;
                    }
            
                    p:has(img) {
                        padding: 0;
                    }
            
                    span {
                        color: \(linkColor.hex) !important;
                    }
            
                    li:last-child {
                        margin-bottom: 1em;
                    }
            
                    img {
                        max-height: 100%;
                        max-width: 100% !important;
                        width: 100%;
                        object-fit: cover;
                        height: auto;
                        margin: 0;
                        padding: 0;
                    }
            
                    figure {
                        width: 100%;
                        margin: 0;
                        padding: 0;
                        max-width: 100% !important;
                        margin-top: 8px;
                        margin-bottom: 8px;
                    }
            
                    figure figcaption {
                        font-size: 0.7rem;
                        margin: 0;
                        padding: 0;
                        opacity: 0.7;
                    }
            
                    iframe {
                        max-width: 100% !important;
                        width: 100% !important;
                    }
            
                    .tiktok-embed {
                        height: 739px !important;
                    }
            
                    .related-article {
                        margin: 8px 0;
                        display: block;
                        width: 100%;
                        box-sizing: border-box;
                        display: flex;
                        align-items: center;
                        background: \(UIColor.secondaryBackground.hex);
                        border-radius: 6px;
                        padding: 12px;
                        flex-direction: row;
                        flex-wrap: wrap;
                    }
            
                    .related-article span {
                        flex: 0 0 100%;
                        color: \(linkColor.hex) !important;
                        font-weight: bolder;
                        text-transform: uppercase;
                        font-size: 0.8rem !important;
                        margin-bottom: 8px;
                    }
            
                    .related-article .related-article-info h3 {
                        font-size: 0.94rem;
                        padding: 0;
                        margin: 0;
                    }
            
                    .related-article p {
                        display: none;
                    }
            
                    .related-article img {
                        border-radius: 8px;
                        width: 110px;
                        height: 80px;
                    }
            
                    .related-article-info {
                        flex: 1;
                        padding: 0;
                        margin: 0;
                        margin-left: 12px;
                    }
            
                    .related-article-info span {
                        display: none;
                    }
            
                    .article-poll {
                        margin: 8px 0;
                        display: block;
                        width: 100%;
                        box-sizing: border-box;
                        background: \(UIColor.secondaryBackground.hex);
                        border-radius: 6px;
                        padding: 12px;
                    }
            
                    .article-poll > span {
                        color: \(UIColor.label.hex) !important;
                        font-size: 1.1rem;
                        font-weight: bold;
                    }
            
                    .article-poll form label {
                        display: block;
                        width: 100%;
                        margin-top: 10px;
                    }
            
                    .article-poll form label span {
                        color: \(UIColor.label.hex) !important;
                    }
            
                    .article-poll form button {
                        display: block;
                        width: 100%;
                        background: none;
                        color: \(UIColor.label.hex) !important;
                        text-transform: uppercase;
                        margin-top: 16px;
                        padding: 14px 0;
                        border: 1px solid \(UIColor.systemGray5.hex);
                        border-radius: 6px;
                        font-size: 0.8rem;
                    }
            
                    .article-poll form a {
                        text-align: center;
                        font-weight: bold;
                        display: block;
                        width: 100%;
                        background: none;
                        color: \(UIColor.label.hex) !important;
                        text-transform: uppercase;
                        margin-top: 16px;
                        padding: 14px 0;
                        font-size: 0.8rem;
                    }
            
                    #back-to-poll {
                        display: block;
                        text-align: center;
                        font-weight: bold;
                        width: 100%;
                        background: none;
                        color: \(UIColor.label.hex) !important;
                        text-transform: uppercase;
                        margin-top: 16px;
                        padding: 14px 0;
                        font-size: 0.8rem;
                    }
            
                    .hidden {
                        display: none !important;
                    }
            
                    #poll-result {
                        width: 100%;
                        margin-top: 12px;
                    }
            
                    #poll-result .relative {
                        position: relative;
                        width: 100%;
                    }
            
                    #poll-result .w-full {
                        width: 100%;
                        overflow: hidden;
                    }
                    
                    #poll-result div {
                        width: 100%;
                    }
            
                    #poll-result .relative .h-2\\.5 div {
                        height: 10px;
                        background-color: yellow;
                        margin-top: 2px;
                        border-radius: 4px;
                    }
            
                    #poll-result span {
                        display: block;
                        color: \(UIColor.label.hex) !important;
                        font-weight: bold;
                        margin-top: 8px;
                        font-size: 0.9rem;
                    }
            
                    p > img {
                        padding: 20px 0px;
                    }
                </style>
            
                <script>
                    function fontSizeChanged(size) {
                        var pixelSize = size + "px";
                        document.documentElement.style.setProperty("font-size", pixelSize);
                    }
                </script>
            </head>
            <body>
                \(processedText)
            </body>
            
            <script>
                function processForm(e) {
                    if (e.preventDefault) e.preventDefault();

                    var form = e.target;
                    var checkedValue = form.querySelector('.form-radio:checked').value;
            
                    var pollData = {
                        'url': form.action,
                        'value': checkedValue
                    };

                    window.webkit.messageHandlers.pollVote.postMessage(JSON.stringify(pollData));

                    return false;
                }
            
                var form = document.getElementById('poll-form');
                if (form.attachEvent) {
                    form.attachEvent("submit", processForm);
                } else {
                    form.addEventListener("submit", processForm);
                }
            
                document.addEventListener("DOMContentLoaded", function(){
                    if (\(showPollResults)) {
                        Poll.showResults();
                    }
                });
            </script>
            </html>
            """
        
        return html
    }
    
    mutating func removingRegexMatches(pattern: String, replaceWith: String = "") {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: count)
            self = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch { return }
    }
}
