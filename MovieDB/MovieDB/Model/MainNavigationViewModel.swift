//
//  MainNavigationViewModel.swift
//  MovieDB
//
//  Created by Przemek Ce on 20/08/2024.
//
import Foundation
import Combine

enum Destination {
    case movieList
    case movieDetails
}

public class MainNavigationViewModel: ObservableObject {
    
    @Published var currentDestination: Destination = .movieList
    var moviesListViewModel: MovieListViewModel

    init(destination: Destination = .movieList) {
        self.currentDestination = destination
        self.moviesListViewModel = MovieListViewModel()
    }
    
    func navigateToMovieDetails() {
        currentDestination = .movieDetails
    }
    
    func navigateToMovieList() {
        currentDestination = .movieList
    }
    
    func checkInitialStatus() {

    }
    
    func getMovieListViewModel() -> MovieListViewModel {
        return moviesListViewModel
    }
}
