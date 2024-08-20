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
            AsyncImage(url: movie.thumbnailUrl) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure:
                    Image("placeholder")
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 50, height: 50)
            .cornerRadius(8)
            
            Spacer()
            
            VStack {
                Text(movie.title)
                Spacer()
                Text(movie.releaseDate)
                    .font(.footnote)
            }
        }
        .padding([.top, .bottom], 8)
    }
}

#Preview {
    MovieCell(movie: MovieViewModel(movie: Movie.mockMovie))
        .frame(width: 50, height: 50)

}
