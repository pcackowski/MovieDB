//
//  MovieCell.swift
//  MovieDB
//
//  Created by Przemek Ce on 20/08/2024.
//

import SwiftUI

struct MovieCell: View {

    @StateObject var movie: MovieViewModel
    
    var movieImage: some View {
        AsyncImage(url: movie.thumbnailUrl) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fill)
            case .failure:
                Image("placeholderMovie")
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 50, height: 50)
        .cornerRadius(8)
    }
    
    var body: some View {
        HStack {
            movieImage
            
            VStack( alignment: .leading) {
                Text(movie.title)
                    .font(.headline)
                Spacer()
                Text("Vote: \(movie.voteAverage)")
                    .font(.caption)
            }
            Spacer()
            StarView(filled: movie.isFavourite)
                .onTapGesture {
                    movie.favButtonTapped()
                }
        }
        .onAppear {
            Task {
                movie.isFavourite = await movie.isFavourite()
            }
        }
        .padding([.top, .bottom], 8)
    }
}

#Preview {
    MovieCell(movie: MovieViewModel(movie: Movie.mockMovie))
        .frame(height: 50)
        .padding(.horizontal, 8)


}
