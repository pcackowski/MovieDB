//
//  MovieViewModel.swift
//  MovieDB
//
//  Created by Przemek Ce on 20/08/2024.
//

import Foundation

struct MovieViewModel {
    private let movie: Movie
    init(movie: Movie) {
        self.movie = movie
    }
    
    var thumbnailUrl: URL {
        return URL(string: "https://image.tmdb.org/t/p/w500\(movie.backdropPath ?? "")")!
    }

    var posterURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath ?? "")")!
    }

    //TODA check N/A
    var voteAverage: String {
        if let movieVote = movie.voteAverage {
            return String(movieVote)
        }
        return "N/A"
    }
    
    var title: String {
        return movie.title ?? ""
    }
    
    var releaseDate: String {
        return movie.releaseDate ?? ""
    }
    
    var overview: String {
        return movie.overview ?? "N/A"
    }
}
