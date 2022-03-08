//
//  RoutesListView.swift
//  Splash
//
//  Created by Shreeya Gad on 3/2/22.
//

import SwiftUI
import FBSDKLoginKit

struct RoutesListView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "username LIKE %@", "Shreeya Gad")) var routes: FetchedResults<Route>
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var locationManager: LocationManager = LocationManager()
    @State private var isPresentingNewRouteView: Bool = false
    @State private var isPresentingFriendsRoutes: Bool = false
    @State private var newRouteData: Route.Data = Route.Data()
    
    @AppStorage("logged") var logged = false
    @State var loginManager = LoginManager()
    @Binding var username: String
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(routes, id: \.id) {
                        route in
                        NavigationLink(destination:
                        RouteDetailView(route: route)
                        .environment(\.managedObjectContext, moc)
                        .environmentObject(locationManager))
                           { Text(route.name ?? "") }
                    }
                    .onDelete { indexSet in
                        for offset in indexSet {
                            let route = routes[offset]
                            moc.delete(route)
                        }
                            // save the context
                        try? moc.save()
                    }
                }
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        loginManager.logOut()
                        viewRouter.currentPage = .signInPage
                        logged = false
                    })
                    {
                        Label("Log Out", systemImage: "arrow.right.to.line").labelStyle(CustomLabelStyle())
                    }
                }.background(Color("ListBGColor"))
                    .offset(x: -25, y: -30)
        }.background(Color("ListBGColor"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { isPresentingNewRouteView = true }) {
                        Label("", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    NavigationLink(destination:
                                    FriendsRouteView()
                        .environment(\.managedObjectContext, moc)
                                    .navigationTitle("Friends' Routes")
                    )
                    {
                        Label("", systemImage: "person.3")
                    }
                }
            }
            .sheet(isPresented: $isPresentingNewRouteView) {
                NavigationView {
                    RouteEditView(routeData: $newRouteData)
                    .navigationTitle("New Route")
                    .environmentObject(locationManager)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Dismiss") {
                                isPresentingNewRouteView = false
                                newRouteData = Route.Data()
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                newRouteData.username = username
                                print("my username: \(username)")
                                Route.addRoute(data: newRouteData, moc: moc)
                                try? moc.save()
                                isPresentingNewRouteView = false
                                newRouteData = Route.Data()
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Routes")
            .onAppear {
                locationManager.checkIfLocationServicesIsEnabled()
            }
        }
    }
}

struct CustomLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}
    

