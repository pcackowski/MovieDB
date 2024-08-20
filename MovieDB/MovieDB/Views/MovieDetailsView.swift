//
//  MovieDetailsView.swift
//  MovieDB
//
//  Created by Przemek Ce on 20/08/2024.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: MovieViewModel
    
    var body: some View {
        VStack() {
            VStack(alignment: .leading, spacing: 10) {
                AsyncImage(url: movie.posterURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fit)
                    case .failure:
                        Image("placeholder")
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 300)
                .cornerRadius(10)
                .padding()
                
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(movie.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Release Date: \(movie.releaseDate)")
                    .font(.subheadline)
                
                Text("Rating: \(movie.voteAverage)")
                    .font(.subheadline)

                Text(movie.overview)
                    .font(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading) 
            .background(.gray)
            .padding(.horizontal)
            Spacer()

        }
        .navigationTitle("Movie details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailView(movie: MovieViewModel(movie: Movie.mockMovie))
    }
}
