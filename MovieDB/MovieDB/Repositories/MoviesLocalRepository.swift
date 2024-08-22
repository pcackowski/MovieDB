//
//  MoviesLocalRepository.swift
//  MovieDB
//
//  Created by Przemek Ce on 20/08/2024.
//

import Foundation
import Combine

protocol UserDefaultsProtocol {
    func set(_ value: Any?, forKey defaultName: String)
    func data(forKey defaultName: String) -> Data?
    func removeObject(forKey defaultName: String)
}

extension UserDefaults: UserDefaultsProtocol {}

protocol MoviesLocalRepositoryProtocol {
    func saveMovie(_ movie: Movie) async throws -> Bool
    func fetchMovies() async throws -> [Movie]
    func deleteMovie(withId id: Int) async throws -> Bool
}

actor MoviesLocalRepository: MoviesLocalRepositoryProtocol {

    private static let moviesKey = "movies"
    private let defaults: UserDefaultsProtocol

    init(defaults: UserDefaultsProtocol =  UserDefaults.standard) {
        self.defaults = defaults
    }
    
    func fetchMovies() async throws -> [Movie] {
        guard let data = self.defaults.data(forKey: Self.moviesKey) else {
            return []
        }
        do {
            let movies = try JSONDecoder().decode([Movie].self, from: data)
            return movies
        } catch {
            throw MoviesPersistenceError.fetchFailed
        }
    }
    
    func saveMovie(_ movie: Movie) async throws -> Bool {
        do {
            var movies = try await fetchMovies()
            movies.append(movie)
            return try await saveMovies(movies)
        } catch {
            throw MoviesPersistenceError.saveFailed
        }
    }
    
    private func saveMovies(_ movies: [Movie]) async throws -> Bool {
        do {
            let data = try JSONEncoder().encode(movies)
            self.defaults.set(data, forKey: Self.moviesKey)
            return true
        } catch {
            throw MoviesPersistenceError.saveFailed
        }
    }
        
    func deleteMovie(withId id: Int) async throws -> Bool {
        do {
            let movies = try await fetchMovies().filter { $0.id != id }
            return try await saveMovies(movies)
        } catch {
            throw MoviesPersistenceError.saveFailed
        }
    }
}

enum MoviesPersistenceError: Error {
    case saveFailed
    case fetchFailed
}
