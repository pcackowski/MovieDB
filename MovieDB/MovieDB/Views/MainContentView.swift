//
//  MainContentView.swift
//  MovieDB
//
//  Created by Przemek Ce on 20/08/2024.
//

import SwiftUI

struct MainContentView: View {
    @StateObject var mainNavigationViewModel: MainNavigationViewModel
    @State private var query = ""
    var body: some View {
        NavigationView {
            VStack {
                MoviesListView(moviesListViewModel: mainNavigationViewModel.getMovieListViewModel())
            }
            .searchable(text: $mainNavigationViewModel.moviesListViewModel.query)
        }
    }
}

#Preview {
    @StateObject var mainNavigationViewModel = MainNavigationViewModel()
    return MainContentView(mainNavigationViewModel: mainNavigationViewModel)
}
