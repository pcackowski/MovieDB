//
//  MovieViewModelTests.swift
//  MovieDBTests
//
//  Created by Przemek Ce on 11/09/2024.
//

import XCTest
@testable import MovieDB

final class MovieViewModelTests: XCTestCase {
        
    func testCheckFavouriteStatus() async {
        let movie = Movie.mockMovie
        let repository = MockMoviesLocalRepository()
        repository.movies = [movie]
        let viewModel = MovieViewModel(movie: movie, localRepository: repository)

        let expectation = XCTestExpectation(description: "isFavourite status updates on main queue")

        let cancellable = viewModel.$isFavourite
            .sink { newValue in
                if newValue == true {
                    expectation.fulfill()
                }
            }

        await viewModel.checkFavouriteStatus()
        await self.fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testToggleFavouriteStatus() async {
        let movie = Movie.mockMovie
        let repository = MockMoviesLocalRepository()
        let viewModel = MovieViewModel(movie: movie, localRepository: repository)

        let firstToggleExpectation = XCTestExpectation(description: "Movie should be marked as favorite after toggling")

        let firstCancellable = viewModel.$isFavourite
            .sink { newValue in
                if newValue == true {
                    firstToggleExpectation.fulfill()
                }
            }


        await viewModel.toggleFavourite()
        
        let secondToggleExpectation = XCTestExpectation(description: "Movie should not be marked as favorite after toggling again")
        let secondCancellable = viewModel.$isFavourite
            .sink { newValue in
                if newValue == false {
                    secondToggleExpectation.fulfill()
                }
            }

        await viewModel.toggleFavourite()
        
        await self.fulfillment(of: [firstToggleExpectation,secondToggleExpectation], timeout: 1.0)
    }
    
    func testVoteAverageFormatting() {
        let movie = Movie.mockMovie
        let viewModel = MovieViewModel(movie: movie)

        XCTAssertEqual(viewModel.voteAverage, "1.0", "Vote average should be formatted correctly")
    }
}

class MockMoviesLocalRepository: MoviesLocalRepositoryProtocol {
    var movies: [Movie] = []

    func fetchMovies() async throws -> [Movie] {
        return movies
    }

    func saveMovie(_ movie: Movie) async throws -> Bool {
        if !movies.contains(where: { $0.id == movie.id }) {
            movies.append(movie)
            return true
        }
        return false
    }

    func deleteMovie(withId id: Int) async throws -> Bool {
        if let index = movies.firstIndex(where: { $0.id == id }) {
            movies.remove(at: index)
            return true
        }
        return false
    }
}
