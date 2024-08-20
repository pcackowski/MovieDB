//
//  MoviesDBRepository.swift
//  MovieDB
//
//  Created by Przemek Ce on 19/08/2024.
//

import Foundation
import Combine

public protocol URLCustomSessionProtocol {
    @available(iOS 13.0, *)
    func customDataTaskPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

extension URLSession: URLCustomSessionProtocol {
    public func customDataTaskPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        return self.dataTaskPublisher(for: request)
            .mapError { $0 as URLError }
            .eraseToAnyPublisher()
    }
}

protocol MoviesDBRepository {
    func fetchMovies(page: Int) -> AnyPublisher<MainResponse, Error>
//    func fetchMovieDetails(movieId: Int) async throws -> Movie
}

struct MoviesDBRepositoryImpl: MoviesDBRepository {
    private let session: URLCustomSessionProtocol
    private static let apiKey = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlZjgyMGVlOTY0OTY1NmNhMjcwOTUwZWFlMGQ0MGEwOCIsIm5iZiI6MTcyNDA5OTEyOS4zMTc3NTgsInN1YiI6IjY2YzNhOTdjM2EyOGNlNDY5Mzk2ZWIyZiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.ZwspJEnm2fYHhMEjCu0oR6G0xqAgnu8EqUpg5cPIasA"
    
    init(session: URLCustomSessionProtocol = URLSession.shared) {
        self.session = session
    }

    func fetchMovies(page: Int) -> AnyPublisher<MainResponse, Error> {
        return buildFetchMoviesRequest(with: page)
            .flatMap { request in
                return session.customDataTaskPublisher(for: request)
                    .validateAndMapErrors()
            }
            .decode(type: MainResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    private func buildFetchMoviesRequest(with page: Int) -> AnyPublisher<URLRequest, MoviesDBError> {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing") else {
            return Fail(error: MoviesDBError.invalidURL).eraseToAnyPublisher()
        }
        
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return Fail(error: MoviesDBError.invalidURL).eraseToAnyPublisher()
        }
        
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1")
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems
        
        guard let finalURL = components.url else {
            return Fail(error: MoviesDBError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(Self.apiKey)"
        ]
        
        return Just(request)
            .setFailureType(to: MoviesDBError.self)
            .eraseToAnyPublisher()
    }
}

enum MoviesDBError: Error, Equatable{
    case invalidURL
    case invalidResponse
    case clientError(statusCode: Int)
    case serverError(statusCode: Int)
    case generalError
    
    public var title: String {
        switch self {
            
        case .clientError:
            return "Verification Failed"
        case .serverError:
            return " Server error"
        case .generalError:
            return "Error"
        default:
            return ""
        }
    }
    
    public var desc: String {
        switch self {
            
        case .clientError:
            return "Your API key is incorrect"
        case .serverError:
            return "We encounterd server issue. Try again"
        case .generalError:
            return "Oops, Something wnet wrong. Try again."
        default:
            return ""
        }
    }
}

extension Publisher where Output == URLSession.DataTaskPublisher.Output, Failure == URLError {
    func validateAndMapErrors() -> AnyPublisher<Data, MoviesDBError> {
        self.tryMap { output in
            guard let httpResponse = output.response as? HTTPURLResponse else {
                throw MoviesDBError.generalError
            }
            switch httpResponse.statusCode {
            case 200...299:
                return output.data
            case 400...499:
                throw MoviesDBError.clientError(statusCode: httpResponse.statusCode)
            case 500...599:
                throw MoviesDBError.serverError(statusCode: httpResponse.statusCode)
            default:
                throw MoviesDBError.generalError
            }
        }
        .mapError { error -> MoviesDBError in
              (error as? MoviesDBError) ?? MoviesDBError.generalError
        }
        .eraseToAnyPublisher()
      }
  }
