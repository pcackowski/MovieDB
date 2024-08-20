//
//  MovieModel.swift
//  MovieDB
//
//  Created by Przemek Ce on 19/08/2024.
//

import Foundation

// MARK: - MainResponse
struct MainResponse: Codable {
    let dates: Dates?
    let page: Int?
    let results: [Movie]?
    let totalPages: Int?
    let totalResults: Int?

    enum CodingKeys: String, CodingKey {
        case dates, page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// MARK: - Dates
struct Dates: Codable {
    let maximum: String?
    let minimum: String?
}

// MARK: - Movie
struct Movie: Codable {
    let adult: Bool?
    let backdropPath: String?
    let genreIDS: [Int]?
    let id: Int?
    let originalLanguage: String?
    let originalTitle: String?
    let overview: String?
    let popularity: Double?
    let posterPath: String?
    let releaseDate: String?
    let title: String?
    let video: Bool?
    let voteAverage: Double?
    let voteCount: Int?

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIDS = "genre_ids"
        case id
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview, popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title, video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    static var mockMovie = Movie(adult: false, backdropPath: "/yDHYTfA3R0jFYba16jBB1ef8oIt.jpg", genreIDS: [1,2,3], id: 1, originalLanguage: "en", originalTitle: "Original Title", overview: "Overview", popularity: 1.0, posterPath: "/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg", releaseDate: "2024-08-19", title: "Title", video: false, voteAverage: 1.0, voteCount: 1)
}


