//
//  ContentView.swift
//  Splash
//
//  Created by Shreeya Gad on 3/1/22.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var viewRouter: ViewRouter
    @State private var username: String = ""
    
    var body: some View {
        switch viewRouter.currentPage {
        case .signInPage:
            LoginView(username: $username).environmentObject(viewRouter)
        case .homePage:
            RoutesListView(username: $username)
                .environment(\.managedObjectContext, moc)
                .environmentObject(viewRouter)
                .environmentObject(locationManager)
        }
    }
}
