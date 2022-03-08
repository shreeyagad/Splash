//
//  FriendRouteCardView.swift
//  Splash
//
//  Created by Shreeya Gad on 3/3/22.
//

import SwiftUI
import CoreData

struct FriendRouteCardView: View {
    @ObservedObject var route: Route
    var body: some View {
        VStack(alignment: .leading) {
            Text(route.name ?? "")
            HStack {
                Text("↪️")
                VStack(alignment: .leading) {
                    Text("\(route.startLocation?.name ?? "")").font(.caption).foregroundColor(.secondary)
                    Text("\(route.endLocation?.name ?? "")").font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                VStack {
                    Text("👤 \(route.username ?? "")").font(.caption).foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
    }
}

struct FriendRouteCardView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = DataController().container.viewContext
        let sampleRoute = Route.sampleData(moc: moc)[0]
        FriendRouteCardView(route: sampleRoute)
    }
}
