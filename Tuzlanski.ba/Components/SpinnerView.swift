//
//  SpinnerView.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 15. 12. 2023..
//

import SwiftUI

struct SpinnerView: View {
    var body: some View {
        ZStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.tintColor)))
                .scaleEffect(2.0, anchor: .center)
                .padding(50)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        }
    }
}
