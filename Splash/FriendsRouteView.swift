//
//  FriendsRouteView.swift
//  Splash
//
//  Created by Shreeya Gad on 3/2/22.
//

import SwiftUI

struct FriendsRouteView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var locationManager: LocationManager
//    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "username LIKE %@", "Lisa Simpson")) var routes: FetchedResults<Route>
    @State private var routeName: String = ""
    
    var body: some View {
        var routes = Route.sampleData(moc: moc)
        return List {
            ForEach(routes, id: \.id) { route in 
                NavigationLink(destination:
                RouteCompareView(theirRoute: route)
                .navigationTitle(route.name ?? "")
                .environment(\.managedObjectContext, moc)
                .environmentObject(locationManager))
               {
                   FriendRouteCardView(route: route)
               }
            }
        }
        .searchable(text: $routeName)
    }
}

struct FriendsRouteView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsRouteView()
    }
}
