//
//  MovieViewModel.swift
//  MovieDB
//
//  Created by Przemek Ce on 19/08/2024.
//

import Foundation
import Combine

enum MoviesListState: Equatable {
    static let loadingMesage = "Loading movies..."
    
    case loading(String)
    case loaded
    case error(MoviesDBError)
}

class MoviesViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var showAlert: Bool = false
    @Published var moviesListState: MoviesListState = .loading(MoviesListState.loadingMesage)

    private let repository: MoviesDBRepository
    
    init(repository: MoviesDBRepository = MoviesDBRepositoryImpl()) {
        self.repository = repository
    }
    
    func fetchMovies() {
        repository.fetchMovies(page: 1)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { [weak self] response in
                self.self?.moviesListState = .loaded
                self?.movies = response.results
            }
            .store(in: &cancellables)
    }
    
    private var cancellables: Set<AnyCancellable> = []
}
