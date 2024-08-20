//
//  MoviesListView.swift
//  MovieDB
//
//  Created by Przemek Ce on 19/08/2024.
//

import SwiftUI

struct MoviesListView: View {
    
    @ObservedObject var moviesListViewModel: MoviesViewModel

    
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
                    HStack {
                        Text(movie.title)
                        Spacer()
                        Text(movie.releaseDate)
                    }
                    .padding([.top, .bottom], 8)
                }
                .listStyle(PlainListStyle())
            }
            .edgesIgnoringSafeArea(.all)
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
            .onAppear {
                moviesListViewModel.fetchMovies()
            }
    
    }
    
    var moviesList: some View {
        List {
            
        }
    }
}

#Preview {
    MoviesListView(moviesListViewModel: MoviesViewModel())
}
