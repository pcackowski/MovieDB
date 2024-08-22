//
//  MovieListViewModelTests.swift
//  MovieDBTests
//
//  Created by Przemek Ce on 22/08/2024.
//

import XCTest
import Combine
@testable import MovieDB

final class MovieListViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    static let movies = [
        Movie(adult: false, backdropPath: "", genreIDS: [], id: 1, originalLanguage: "PL", originalTitle: "Movie title 1 ", overview: "", popularity: 1.0, posterPath: "", releaseDate: "", title: "", video: false, voteAverage: 1.0, voteCount: 1),
        Movie(adult: false, backdropPath: "", genreIDS: [], id: 2, originalLanguage: "PL", originalTitle: "Movie title 2", overview: "", popularity: 1.0, posterPath: "", releaseDate: "", title: "", video: false, voteAverage: 1.0, voteCount: 1),
        Movie(adult: false, backdropPath: "", genreIDS: [], id: 3, originalLanguage: "PL", originalTitle: "Movie title 3", overview: "", popularity: 1.0, posterPath: "", releaseDate: "", title: "", video: false, voteAverage: 1.0, voteCount: 1)]
    
    func testFetchMovies() {

        let repository = MockMoviesDBRepository()
        repository.fetchMoviesResult = .success(MainResponse(dates: nil, page: 1, results: MovieListViewModelTests.movies, totalPages: 1, totalResults: 1))
        let viewModelSUT = MovieListViewModel(repository: repository)
        
        viewModelSUT.fetchMovies()
        _ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 0.01)

        XCTAssertTrue(viewModelSUT.moviesListState == .loaded)
        XCTAssertTrue(viewModelSUT.movies == MovieListViewModelTests.movies)
    }
    
    func testFetchMoviesFailure() {

        let repository = MockMoviesDBRepository()
        repository.fetchMoviesResult = .failure(MoviesDBError.clientError(statusCode: 401))
        let viewModelSUT = MovieListViewModel(repository: repository)

        viewModelSUT.fetchMovies()
        _ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 0.01)

        switch viewModelSUT.moviesListState {
            
        case .error(let clientError):
            XCTAssertTrue(viewModelSUT.movies.count == 0)
            XCTAssertTrue(clientError.localizedDescription == MoviesDBError.clientError(statusCode: 401).localizedDescription)
        default:
            XCTFail("Test failed")
        }
    }
    
    func testSetupAutocompleteTriggersSearch() {
        let mockRepository = MockMoviesDBRepository()
        let expectedMovies = MovieListViewModelTests.movies
        mockRepository.searchMoviesResult = .success(MainResponse(dates: nil, page: 1, results: expectedMovies, totalPages: 1, totalResults: 1))

        let viewModelSUT = MovieListViewModel(repository: mockRepository)
        
        let expectation = XCTestExpectation(description: "Autocomplete search triggers after debounce")
        
        viewModelSUT.$movies
            .dropFirst()
            .sink { movies in
                XCTAssertEqual(movies, expectedMovies, "Movies should match the expected search results.")
                XCTAssertTrue(viewModelSUT.isAutocompleteMode)
                XCTAssertTrue(viewModelSUT.moviesListState == .loaded)

                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModelSUT.query = "Test"
        
        wait(for: [expectation], timeout: 1.0)
    }

    
}

class MockMoviesDBRepository: MoviesDBRepository {
    var fetchMoviesResult: Result<MainResponse, MoviesDBError>?
    var searchMoviesResult: Result<MainResponse, MoviesDBError>?
    
    func fetchMovies(page: Int) -> AnyPublisher<MainResponse, MoviesDBError> {
        Future<MainResponse, MoviesDBError> { promise in
            if let result = self.fetchMoviesResult {
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }
    
    func searchMovies(query: String) -> AnyPublisher<MainResponse, MoviesDBError> {
        Future<MainResponse, MoviesDBError> { promise in
            if let result = self.searchMoviesResult {
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }
}
