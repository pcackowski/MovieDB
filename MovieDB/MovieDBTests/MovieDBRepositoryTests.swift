//
//  MovieDBRepositoryTests.swift
//  MovieDBTests
//
//  Created by Przemek Ce on 22/08/2024.
//

import XCTest
import Combine
@testable import MovieDB

final class MovieDBRepositoryTests: XCTestCase {

    
    private var cancellables = Set<AnyCancellable>()

    static let storedMoviesJSON = """
    {
      "dates": {
        "maximum": "2024-08-28",
        "minimum": "2024-07-17"
      },
      "page": 1,
      "results": [
        {
          "adult": false,
          "backdrop_path": "/yDHYTfA3R0jFYba16jBB1ef8oIt.jpg",
          "genre_ids": [
            28,
            35,
            878
          ],
          "id": 533535,
          "original_language": "en",
          "original_title": "Deadpool & Wolverine",
          "overview": "A listless Wade Wilson toils away in civilian life with his days as the morally flexible mercenary, Deadpool, behind him. But when his homeworld faces an existential threat, Wade must reluctantly suit-up again with an even more reluctant Wolverine.",
          "popularity": 6334.004,
          "poster_path": "/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg",
          "release_date": "2024-07-24",
          "title": "Deadpool & Wolverine",
          "video": false,
          "vote_average": 7.763,
          "vote_count": 2159
        },
        {
          "adult": false,
          "backdrop_path": "/p5ozvmdgsmbWe0H8Xk7Rc8SCwAB.jpg",
          "genre_ids": [
            16,
            10751,
            12,
            35
          ],
          "id": 1022789,
          "original_language": "en",
          "original_title": "Inside Out 2",
          "overview": "Teenager Riley's mind headquarters is undergoing a sudden demolition to make room for something entirely unexpected: new Emotions! Joy, Sadness, Anger, Fear and Disgust, who’ve long been running a successful operation by all accounts, aren’t sure how to feel when Anxiety shows up. And it looks like she’s not alone.",
          "popularity": 3413.374,
          "poster_path": "/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg",
          "release_date": "2024-06-11",
          "title": "Inside Out 2",
          "video": false,
          "vote_average": 7.648,
          "vote_count": 2671
        },
        {
          "adult": false,
          "backdrop_path": "/58D6ZAvOKxlHjyX9S8qNKSBE9Y.jpg",
          "genre_ids": [
            28,
            12,
            18,
            53
          ],
          "id": 718821,
          "original_language": "en",
          "original_title": "Twisters",
          "overview": "As storm season intensifies, the paths of former storm chaser Kate Carter and reckless social-media superstar Tyler Owens collide when terrifying phenomena never seen before are unleashed. The pair and their competing teams find themselves squarely in the paths of multiple storm systems converging over central Oklahoma in the fight of their lives.",
          "popularity": 2373.617,
          "poster_path": "/pjnD08FlMAIXsfOLKQbvmO0f0MD.jpg",
          "release_date": "2024-07-10",
          "title": "Twisters",
          "video": false,
          "vote_average": 7.065,
          "vote_count": 942
        },
      ],
      "total_pages": 183,
      "total_results": 3645
    }
    """

    
    func testFetchMovies() {
        // Given
        let mockSession = MoviesMockSession(reponseMovies: Self.storedMoviesJSON)
        let repository = MoviesDBRepositoryImpl(session: mockSession)
        let expectation = XCTestExpectation(description: "Fetch movies")
        let decoder = JSONDecoder()
        var expectedMovies: [Movie] = []
        do {
            let mainResponse = try decoder.decode(MainResponse.self, from: Self.storedMoviesJSON.data(using: .utf8)!)
            expectedMovies = mainResponse.results!
        } catch {
            XCTFail("Decoding storedMoviesJSON failed with error: \(error)")
            return
        }
        // When
        repository
            .fetchMovies(page: 1)
            .sink { sub in
                
            } receiveValue: { movies in
                // Then
                XCTAssertEqual(movies.results, expectedMovies, "Fetched movies do not match expected movies.")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFailFetchMovies() {
        // Given
        let mockSession = MoviesFailMockSession()
        let repository = MoviesDBRepositoryImpl(session: mockSession)
        let expectation = XCTestExpectation(description: "Fetch movies fail")
        // When
        repository
            .fetchMovies(page: 1)
            .sink { sub in
                switch sub {
                    
                case .finished:
                    print("Finished")
                case .failure(let error):
                    // Then
                    XCTAssertEqual(error, MoviesDBError.generalError, "Errors do not match.")
                    expectation.fulfill()

                }
            } receiveValue: { movies in

            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
    
}

class MoviesMockSession: URLCustomSessionProtocol {

    private let reponseMovies: String
    init(reponseMovies: String) {
        self.reponseMovies = reponseMovies
    }
    
    func customDataTaskPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        
        if let moviesData = reponseMovies.data(using: .utf8),
            let mockResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "1", headerFields: [:]) {
            
            return Just((data: moviesData, response: mockResponse))
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()
        }
        return Fail(error: URLError(.badServerResponse))
            .eraseToAnyPublisher()
        
    }
}


class MoviesFailMockSession: URLCustomSessionProtocol {

    func customDataTaskPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        
        return Fail(error: URLError(.badServerResponse))
            .eraseToAnyPublisher()

    }
}
