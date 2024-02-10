//
//  String+HTML.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 18. 11. 2023..
//

import UIKit

extension String {
    
    func wrappedInHTML(linkColor: UIColor = .tintColor) -> String {
        
        var processedText = self.replacingOccurrences(of: "\r\n", with: "<br>")
        processedText.removingRegexMatches(pattern: "\\[gallery.*\\]")
        
        processedText = processedText.replacingOccurrences(of: "src=\"https://dev.tuzlanski.ba/assets/img/lazy.png\"", with: "")
        processedText = processedText.replacingOccurrences(of: "data-src=", with: "src=")
        
        return """
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
                    @font-face { font-family: 'Montserrat'; src: url('Montserrat-Medium.ttf') format('truetype'); font-weight: 400; }
                    @font-face { font-family: 'Montserrat'; src: url('Montserrat-SemiBold.ttf') format('truetype'); font-weight: 600; }
                    @font-face { font-family: 'Montserrat'; src: url('Montserrat-Bold.ttf') format('truetype'); font-weight: 700; }
            
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
                    }
            
                    iframe {
                        max-width: 100% !important;
                        width: 100% !important;
                    }
            
                    .tiktok-embed {
                        height: 739px !important;
                    }
            
                    .related-article {
                        margin: 0;
                        display: block;
                        width: 100%;
                        box-sizing: border-box;
                        display: flex;
                        align-items: center;
                        background: \(UIColor.systemGray6.hex);
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
            </html>
            """
    }
    
    mutating func removingRegexMatches(pattern: String, replaceWith: String = "") {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: count)
            self = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch { return }
    }
}
