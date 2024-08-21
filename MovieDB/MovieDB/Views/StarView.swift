//
//  StarView.swift
//  MovieDB
//
//  Created by Przemek Ce on 21/08/2024.
//

import SwiftUI

struct StarView: View {
    var filled: Bool
    
    var body: some View {
        Image(systemName: "star.fill")
            .foregroundStyle(filled ? .orange : .gray)
    }
}

struct StarView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            StarView(filled: true)
            StarView(filled: false)
        }
    }
}
