//
//  EmbeddedCommentView.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 21. 12. 2023..
//

import UIKit
import SwiftUI

struct EmbeddedCommentView: View {
    
    var comment: Comment
    
    var body: some View {
        VStack(spacing: 1) {
            Text(comment.name)
                .font(Font(UIFont.Montserrat(.bold, size: 12)))
                .foregroundStyle(Color.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(comment.content)
                .font(Font(UIFont.Montserrat(.semibold, size: 14)))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 3)
        }
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(UIColor.systemGray6))
        }
    }
}
