//
//  MainContentView.swift
//  MovieDB
//
//  Created by Przemek Ce on 20/08/2024.
//

import SwiftUI

struct MainContentView: View {
    
    @StateObject var mainNavigationViewModel = MainNavigationViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Text Field
                SearchFieldView(query: $mainNavigationViewModel.moviesListViewModel.query)
                
                // Movies List View
                MoviesListView(moviesListViewModel: mainNavigationViewModel.getMovieListViewModel())
            }
        }
    }
}

#Preview {
    MainContentView()
}
