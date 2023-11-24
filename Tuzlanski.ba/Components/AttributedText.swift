//
//  AttributedText.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 18. 11. 2023..
//

import SwiftUI

struct AttributedText: UIViewRepresentable {
    typealias UIViewType = UILabel
    
    private let attributedString: NSAttributedString
    
    init(attributedString: NSAttributedString) {
        self.attributedString = attributedString
    }
    
    func makeUIView(context: Context) -> UIViewType {
        let view = UILabel()
        view.backgroundColor = .clear
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        view.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 16 - 16
        return view
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = attributedString
        uiView.sizeToFit()
        uiView.invalidateIntrinsicContentSize()
        uiView.relayout()
    }
}

struct AttributedTextView: UIViewRepresentable {
    typealias UIViewType = UITextView
    
    private let attributedString: NSAttributedString
    private var delegate: UITextViewDelegate?
    
    init(attributedString: NSAttributedString, delegate: UITextViewDelegate? = nil) {
        self.attributedString = attributedString
        self.delegate = delegate
    }
    
    func makeUIView(context: Context) -> UIViewType {
        let view = ContentTextView().forAutoLayout()
        view.setContentHuggingPriority(.required, for: .vertical)
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.contentInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.delegate = delegate
        view.backgroundColor = .clear
        view.isScrollEnabled = false
        view.attributedText = self.attributedString
        view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 16 - 16).isActive = true
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = self.attributedString
        uiView.invalidateIntrinsicContentSize()
        uiView.relayout()
    }
    
    /// ContentTextView
    /// subclass of UITextView returning contentSize as intrinsicContentSize
    private class ContentTextView: UITextView {
        override var canBecomeFirstResponder: Bool { false }
        
        override var intrinsicContentSize: CGSize {
            frame.height > 0 ? contentSize : super.intrinsicContentSize
        }
    }
}
