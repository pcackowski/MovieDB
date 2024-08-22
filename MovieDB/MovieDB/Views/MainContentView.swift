//
//  MainContentView.swift
//  MovieDB
//
//  Created by Przemek Ce on 20/08/2024.
//

import SwiftUI

struct MainContentView: View {
    @StateObject var movieListViewModel = MovieListViewModel()

    var body: some View {
        NavigationView {
            VStack {
                MoviesListView(moviesListViewModel: movieListViewModel)
            }
            .searchable(text: $movieListViewModel.query)
        }
    }
}

#Preview {
    return MainContentView()
}
