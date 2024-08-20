//
//  LoadingView.swift
//  MovieDB
//
//  Created by Przemek Ce on 19/08/2024.
//

import SwiftUI

struct LoadingView: View {
    
    @State var message: String
    var body: some View {
        VStack {
            Spacer()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
            
            Text("\(message)")
                .foregroundColor(.gray)
                .padding(.top, 8)
            
            Spacer()
        }
    }
}

#Preview {
    LoadingView(message: "Loading ...")
}

