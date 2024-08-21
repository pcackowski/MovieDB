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

class MovieListViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var showAlert: Bool = false
    @Published var moviesListState: MoviesListState = .loading(MoviesListState.loadingMesage)
    @Published var query: String = "" {
        didSet {
            print("Viewmodel Query updated to: \(query)")
        }
    }
    
    private let repository: MoviesDBRepository
    private var cancellables: Set<AnyCancellable> = []
    private var favorites: [Movie] = []
    
    init(repository: MoviesDBRepository = MoviesDBRepositoryImpl()) {
        self.repository = repository
        self.setupAutocomplete()
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
                self?.moviesListState = .loaded
                self?.movies = response.results ?? []
            }
            .store(in: &cancellables)
    }
    
    func setupAutocomplete() {
        //todo: add debounce, check if necessary
        $query
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .combineLatest($query)
            .sink { [weak self] previousQuery, currentQuery in
                if !previousQuery.isEmpty && currentQuery.isEmpty {
                    self?.fetchMovies()
                }
            }
            .store(in: &cancellables)
        
        $query
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .flatMap { [weak self, repository] query -> AnyPublisher<MainResponse, Error> in
                self?.moviesListState = .loading("Searching for \(query)...")
                print("Searching for \(query)...")
                return repository.searchMovies(query: query)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    if let error = error as? MoviesDBError {
                        self?.moviesListState = .error(error)
                    } else {
                        self?.moviesListState = .error(MoviesDBError.generalError)
                    }
                    self?.showAlert = true
                }
            } receiveValue: { [weak self] response in
                self?.moviesListState = .loaded
                self?.movies = response.results ?? []
            }
            .store(in: &cancellables)
    }
    

}
