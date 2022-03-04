//
//  SplashApp.swift
//  Splash
//
//  Created by Shreeya Gad on 3/1/22.
//

import SwiftUI
import CoreData
import Firebase
import FBSDKLoginKit

@main
struct SplashApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var dataController = DataController()
    @StateObject var viewRouter = ViewRouter()
    
    @State private var locationManager = LocationManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(locationManager)
                .environmentObject(viewRouter)
        }
    }
}
