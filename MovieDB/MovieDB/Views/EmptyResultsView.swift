//
//  EmptyResultsView.swift
//  MovieDB
//
//  Created by Przemek Ce on 21/08/2024.
//

import SwiftUI

struct EmptyResultsView: View {
    var body: some View {
        Text("Results not found")
            .font(.largeTitle)
            .foregroundColor(.gray)
            .padding(.top, 8)
    }
}

#Preview {
    EmptyResultsView()
}
