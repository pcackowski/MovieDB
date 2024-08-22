//
//  MovieLocalRepositoryTests.swift
//  MovieDBTests
//
//  Created by Przemek Ce on 22/08/2024.
//

import XCTest
@testable import MovieDB

final class MovieLocalRepositoryTests: XCTestCase {
    var repository: MoviesLocalRepository!
    
    func testSaveFetchingMovies() async throws {
        repository = MoviesLocalRepository(defaults: MockUserDefaults())
        let saved = try await repository.saveMovie(Movie.mockMovie)
        let movies = try await repository.fetchMovies()
        
        XCTAssertEqual(movies.count, 1, "Fetched movies count should match the expected value.")
    }

    func testDeleteFetchingMovies() async throws {
        repository = MoviesLocalRepository(defaults: MockUserDefaults())
        let saved = try await repository.saveMovie(Movie.mockMovie)
        let movies = try await repository.fetchMovies()
        
        XCTAssertEqual(movies.count, 1, "Fetched movies count should match the expected value.")
        let removed = try await repository.deleteMovie(withId: Movie.mockMovie.id ?? -1)
        XCTAssertTrue(removed, "Movie should be removed")
        let emptyMovies = try await repository.fetchMovies()
        XCTAssertEqual(emptyMovies.count, 0, "Fetched movies count should be zero")
    }

    
}

class MockUserDefaults: UserDefaultsProtocol {
    
    private var storage: [String: Any] = [:]
    func set(_ value: Any?, forKey defaultName: String) {
        storage[defaultName] = value
    }
    
    func data(forKey defaultName: String) -> Data? {
        if let foundData = storage[defaultName] as? Data {
            return foundData
        }
        return nil
    }
    
    func removeObject(forKey defaultName: String) {
        storage.removeValue(forKey: defaultName)
    }
    
    
}
