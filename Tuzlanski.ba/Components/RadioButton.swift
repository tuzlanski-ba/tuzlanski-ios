//
//  RadioButton.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 21. 12. 2023..
//

import SwiftUI

/// An indicator for showing when an item is selected
struct SelectionIndicator: View {

    /// The size for the indicator
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 20

    /// The line width for stroking the unselected indicator
    @ScaledMetric(relativeTo: .body) private var lineWidth: CGFloat = 1.5

    /// Flag that determines whether the indicator is shown as
    /// selected (true) or not (false)
    private let isSelected: Bool

    /// Creates an indicator to reflect the supplied state.
    /// No gesture handlers are added here. For this reason,
    /// no bindings need to be supplied (the value is
    /// read-only, it is not updated here).
    init(isSelected: Bool) {
        self.isSelected = isSelected
    }

    var body: some View {
        if isSelected {
            // Show a round shape with a transparent tick
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFill()
                .foregroundColor(Color(UIColor.tintColor))
                .frame(width: size + lineWidth, height: size + lineWidth)
        } else {
            // Just show an empty ring
            Circle()
                .stroke(lineWidth: lineWidth)
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .frame(width: size, height: size)
                .padding(lineWidth / 2)
        }
    }
}
