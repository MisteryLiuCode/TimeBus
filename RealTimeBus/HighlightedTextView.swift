//
//  HighlightedTextView.swift
//  RealTimeBus
//
//  Created by 刘帅彪 on 2024/5/19.
//


import SwiftUI
import Combine

struct HighlightedTextView: View {
    let text: String
    let searchText: String
    var body: some View {
        if let range = text.range(of: searchText, options: .caseInsensitive), !searchText.isEmpty {
            let prefixString = String(text[..<range.lowerBound])
            let highlightedString = String(text[range])
            let postfixString = String(text[range.upperBound...])

            return Text(prefixString) + Text(highlightedString).foregroundColor(.blue) + Text(postfixString)
        } else {
            return Text(text)
        }
    }
}
