//
//  RouteSelectorView.swift
//  Splash
//
//  Created by Shreeya Gad on 3/3/22.
//

import SwiftUI

struct RouteSelectorView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "username LIKE %@", "Shreeya Gad")) var routes: FetchedResults<Route>
    @Binding var myRoute: Route
    var body: some View {
        Picker("My Route", selection: $myRoute){
            ForEach(routes, id: \.id) { route in RoutePickerCardView(route: route).tag(route)
            }
        }
    }
}


