//
//  MoviesListView.swift
//  MovieDB
//
//  Created by Przemek Ce on 19/08/2024.
//

import SwiftUI

struct MoviesListView: View {
    
    @ObservedObject var moviesListViewModel: MovieListViewModel
    
    @ViewBuilder private var content: some View {
        switch moviesListViewModel.moviesListState {
        case .loading(let message):
            LoadingView(message: message)
        case .error(let error):
            VStack {
                Spacer()
                Text(error.title)
                    .font(.title)
                Text(error.desc)
                    .font(.subheadline)
                Spacer()
            }
        case .loaded:
            VStack(alignment: .leading) {
                
                List(moviesListViewModel.movies, id: \.id) { movie in
                    NavigationLink(destination: MovieDetailView(movie: MovieViewModel(movie: movie))) {
                        MovieCell(movie: MovieViewModel(movie: movie))
                            .frame(height: 50)
                    }
                }
                .listStyle(GroupedListStyle())
            }
            .background(Color.white)
            
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
            .edgesIgnoringSafeArea([.bottom, .leading, .trailing])
            .onAppear {
                moviesListViewModel.fetchMovies()
            }
    }
}

#Preview {
    MoviesListView(moviesListViewModel: MovieListViewModel())
}
