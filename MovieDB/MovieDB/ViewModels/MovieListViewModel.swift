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
    @Published var isAutocompleteMode: Bool = false
    @Published var moviesListState: MoviesListState = .loading(MoviesListState.loadingMesage) {
        didSet {
            print("MoviesListState: \(moviesListState)")
        }
    }
    @Published var query: String = ""
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 0

    private let repository: MoviesDBRepository
    private var cancellables: Set<AnyCancellable> = []
    private var favorites: [Movie] = []
    
    init(repository: MoviesDBRepository = MoviesDBRepositoryImpl()) {
        self.repository = repository
        self.setupAutocomplete()
        self.fetchMovies()
    }
    
    func loadPreviousPage() {
        currentPage -= 1
        fetchMovies()
    }
    
    func loadNextPage() {
        currentPage += 1
        fetchMovies()
    }
    
    func fetchMovies() {
        self.moviesListState = .loading(MoviesListState.loadingMesage)
        self.isAutocompleteMode = false
        repository.fetchMovies(page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                    self?.moviesListState = .error(error)
                }
            } receiveValue: { [weak self] response in
                self?.moviesListState = .loaded
                self?.movies = response.results ?? []
                self?.totalPages = response.totalPages ?? 0
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
            .flatMap { [weak self, repository] query -> AnyPublisher<MainResponse, MoviesDBError> in
                self?.moviesListState = .loading("Searching for \(query)...")
                self?.isAutocompleteMode = true
                print("Searching for \(query)...")
                return repository.searchMovies(query: query)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.moviesListState = .error(error)
                    self?.showAlert = true
                }
            } receiveValue: { [weak self] response in
                self?.moviesListState = .loaded
                self?.movies = response.results ?? []
            }
            .store(in: &cancellables)
    }
    

}
