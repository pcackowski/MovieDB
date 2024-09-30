//
//  MovieViewModel.swift
//  MovieDB
//
//  Created by Przemek Ce on 20/08/2024.
//

import Foundation
import SwiftUI

struct MovieConsts {
    static let imageURLPrefix = "https://image.tmdb.org/t/p/w500"
    static let notApplicable = "N/A"
}

class MovieViewModel: ObservableObject {
    
    @Published var isFavourite: Bool = false

    private let movie: Movie
    private let localRepository: MoviesLocalRepositoryProtocol
    init(movie: Movie,
         localRepository: MoviesLocalRepositoryProtocol = MoviesLocalRepository()) {
        self.movie = movie
        self.localRepository = localRepository
    }
    
    func checkFavouriteStatus() async {
        let currentFavouriteStatus = await self.isFavourite()
        DispatchQueue.main.async {
            self.isFavourite = currentFavouriteStatus
        }
    }
    
    var thumbnailUrl: URL? {
        return URL(string: "\(MovieConsts.imageURLPrefix)\(movie.backdropPath ?? "")")
    }
    
    var posterURL: URL? {
        return URL(string: "\(MovieConsts.imageURLPrefix)\(movie.posterPath ?? "")")
    }
    
    var voteAverage: String {
        if let movieVote = movie.voteAverage {
            return String((movieVote * 10).rounded(.toNearestOrAwayFromZero) / 10)
        }
        return MovieConsts.notApplicable
    }
    
    var title: String {
        return movie.title ?? ""
    }
    
    var releaseDate: String {
        guard let dateString = movie.releaseDate, let date = DateFormatterManager.shared.releaseDateFormatter.date(from: dateString) else {
            return MovieConsts.notApplicable
        }
        return DateFormatterManager.shared.displayDateFormatter.string(from: date)
    }
    var overview: String {
        return movie.overview ?? MovieConsts.notApplicable
        
    }
    
    func favButtonTapped() {
        Task {
            await toggleFavourite()
        }
    }
    
    func isFavourite() async -> Bool {
        do {
            let movies = try await localRepository.fetchMovies()
            return movies.contains(where: { $0.id == movie.id })
        } catch {
            return false
        }
    }
    
    func saveToFavourites() async -> Bool {
        do {
            return try await localRepository.saveMovie(movie)
        } catch {
            return false
        }
    }
    
    func unsaveFromFavourites() async -> Bool {
        do {
            if let movieId = movie.id {
                return try await localRepository.deleteMovie(withId: movieId)
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    func toggleFavourite() async {
        let currentFavouriteStatus = await self.isFavourite()
        if currentFavouriteStatus {
            let _ =  await self.unsaveFromFavourites()
        } else {
            let _ = await self.saveToFavourites()
        }
        DispatchQueue.main.async {
            self.isFavourite = !currentFavouriteStatus
        }
    }

}
