//
//  RouteCompareView.swift
//  Splash
//
//  Created by Shreeya Gad on 3/2/22.
//

import SwiftUI

struct RouteCompareView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var theirRoute: Route
    @State private var isPresentingMapView: Bool = false
    @State private var isPresentingCompareView: Bool = false
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        List {
            Section(header: Text("Starting Location")) {
                Text(theirRoute.startLocation?.name ?? "")
                Text(theirRoute.startLocation?.address ?? "").foregroundColor(.secondary)
            }
            Section(header: Text("Ending Location")) {
                Text(theirRoute.endLocation?.name ?? "")
                Text(theirRoute.endLocation?.address ?? "").foregroundColor(.secondary)
            }
            Section(header: Text("Route Details")) {
                Text("\(Double(round(theirRoute.expectedTravelTime / 60 * 10) / 10), specifier: "%.1f") minutes")
                Text("\(Double(round(theirRoute.distance / 1609 * 10) / 10), specifier: "%.1f") miles").foregroundColor(.secondary)
            }
            Button(action: {
                isPresentingCompareView = true
            }) { Text("Compare") }
        }
        .sheet(isPresented: $isPresentingCompareView) {
            NavigationView {
                RouteSelectView(theirRoute: theirRoute, isPresentingCompareView: $isPresentingCompareView)
                    .environmentObject(locationManager)
                    .environment(\.managedObjectContext, moc)
                    .navigationTitle("Compare")
            }
        }
        .task {
            await Route.calculateRouteDetails(route: theirRoute)
            try? moc.save()
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    isPresentingMapView = true
                }) {
                    Label("", systemImage: "map")
                }
            }
        }
        .sheet(isPresented: $isPresentingMapView) {
            NavigationView {
                MapView(moc: _moc, locationManager: _locationManager, route: theirRoute)
                    .navigationTitle(theirRoute.name ?? "")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button(action: {
                                isPresentingMapView = false
                            }) {
                                Text("Open in Maps")
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button(action: {
                                isPresentingMapView = false
                            }) {
                                Text("Dismiss")
                            }
                        }
                    }
                
            }
        }
    }
}

struct RouteCompareView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = DataController().container.viewContext
        let sampleRoute = Route.sampleData(moc: moc)[0]
        let locationManager = LocationManager()
        return RouteCompareView(theirRoute: sampleRoute).environmentObject(locationManager)
            .environment(\.managedObjectContext, moc)
    }
}
