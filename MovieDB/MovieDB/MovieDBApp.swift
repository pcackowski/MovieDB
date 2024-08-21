//
//  MovieDBApp.swift
//  MovieDB
//
//  Created by Przemek Ce on 19/08/2024.
//

import SwiftUI

@main
struct MovieDBApp: App {
    var mainNavigationViewModel = MainNavigationViewModel()

    var body: some Scene {
        WindowGroup {
            MainContentView(mainNavigationViewModel: mainNavigationViewModel)
        }
    }
}
