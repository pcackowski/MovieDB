//
//  MovieDetailsView.swift
//  MovieDB
//
//  Created by Przemek Ce on 20/08/2024.
//

import SwiftUI

struct MovieImageView: View {
    let movie: MovieViewModel
    let contentMode: ContentMode
    
    var body: some View {
        AsyncImage(url: movie.posterURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image.resizable().aspectRatio(contentMode: contentMode)
            case .failure:
                Image("placeholderMovie")
            @unknown default:
                EmptyView()
            }
        }
    }
}
struct MovieDetailView: View {
    @ObservedObject var movie: MovieViewModel
    
    var movieImage: some View {
        MovieImageView(movie: movie, contentMode: .fit)
            .frame(height: 300)
            .cornerRadius(10)
            .padding()
    }
    
    var body: some View {
        VStack() {
            movieImage

            VStack(alignment: .leading, spacing: 10) {
                Text(movie.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                                
                Text("Rating: \(movie.voteAverage)")
                    .font(.title3)
                
                Text("Release Date: \(movie.releaseDate)")
                    .font(.subheadline)

                Text(movie.overview)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity, alignment: .leading) 
            .padding(.horizontal)
            Spacer()
        }
        .navigationTitle("Movie details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: starView)
        .task {
            await movie.checkFavouriteStatus()
        }
    }
    
    var starView: some View {
        StarView(filled: movie.isFavourite)
            .onTapGesture {
                movie.favButtonTapped()
            }
    }
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailView(movie: MovieViewModel(movie: Movie.mockMovie))
    }
}
