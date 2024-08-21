//
//  MoviesListView.swift
//  MovieDB
//
//  Created by Przemek Ce on 19/08/2024.
//

import SwiftUI

struct MoviesListView: View {
    
    @StateObject var moviesListViewModel: MovieListViewModel
    @State private var selectedMovie: MovieViewModel?

    @ViewBuilder private var content: some View {
        switch moviesListViewModel.moviesListState {
        case .loading(let message):
            LoadingView(message: message)
        case .error(let error):
            errorView(for: error)
        case .loaded:
            listView
        }
    }
    
    func errorView(for error: MoviesDBError) -> some View {
        VStack {
            Spacer()
            Text(error.title)
                .font(.title)
            Text(error.desc)
                .font(.subheadline)
            Spacer()
        }
    }
    
    @ViewBuilder var listView: some View {
        if moviesListViewModel.movies.isEmpty {
            EmptyResultsView()
        } else {
            moviesList
        }
    }
    
    var moviesList: some View {
        VStack {
            
            List(moviesListViewModel.movies, id: \.id) { movie in
                ZStack(alignment: .leading) {
                    MovieCell(movie: MovieViewModel(movie: movie))
                        .frame(height: 50)
                    NavigationLink(destination: MovieDetailView(movie: MovieViewModel(movie: movie))) {
                        EmptyView()
                    }
                    .opacity(0.0)
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(DefaultListStyle())

            Spacer()
            if moviesListViewModel.isAutocompleteMode {
                EmptyView()
            } else {
                pagesView
            }
        }

    }
    
    var pagesView: some View {
        HStack {
            Button(action: {
                moviesListViewModel.loadPreviousPage()
            }) {
                Image(systemName: "arrow.left")
            }
            .disabled(moviesListViewModel.currentPage <= 1)

            Text("Page \(moviesListViewModel.currentPage) of \(moviesListViewModel.totalPages)")
                .font(.caption)

            Button(action: {
                moviesListViewModel.loadNextPage()
            }) {
                Image(systemName: "arrow.right")
            }
            .disabled(moviesListViewModel.currentPage >= moviesListViewModel.totalPages)
        }
    }
        
    var body: some View {
        content
            .alert(isPresented: $moviesListViewModel.showAlert) {
                return Alert(
                    title: Text("\(MoviesDBError.generalError.title)"),
                    message: Text("\(MoviesDBError.generalError.desc)"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .edgesIgnoringSafeArea([.leading, .trailing])
    }
}

#Preview {
    MoviesListView(moviesListViewModel: MovieListViewModel())
}
