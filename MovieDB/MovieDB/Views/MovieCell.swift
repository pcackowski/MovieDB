//
//  MovieCell.swift
//  MovieDB
//
//  Created by Przemek Ce on 20/08/2024.
//

import SwiftUI

struct MovieCell: View {
    
    var movie: MovieViewModel
    var body: some View {
        HStack {
            AsyncImage(url: movie.thumbnailUrl)
                .frame(width: 50, height: 50)
                .cornerRadius(8)
            Text(movie.title)
            Spacer()
            Text(movie.releaseDate)
        }
        .padding([.top, .bottom], 8)
    }
}

#Preview {
    MovieCell(movie: MovieViewModel(movie: Movie.mockMovie))
}
