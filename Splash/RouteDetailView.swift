//
//  RouteDetailView.swift
//  Splash
//
//  Created by Shreeya Gad on 3/1/22.
//

import SwiftUI
import MapKit

struct RouteDetailView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var locationManager: LocationManager
    @ObservedObject var route: Route
    
    @State private var isPresentingMapView: Bool = false
    
    var body: some View {
        List {
            Section(header: Text("Starting Location")) {
                Text(route.startLocation?.name ?? "")
                Text(route.startLocation?.address ?? "").foregroundColor(.secondary)
            }
            Section(header: Text("Ending Location")) {
                Text(route.endLocation?.name ?? "")
                Text(route.endLocation?.address ?? "").foregroundColor(.secondary)
            }
//            Section(header: Text("Coordinates")) {
//                Text("\(route.startLocation?.coordinate.latitude ?? 0)")
//                Text("\(route.startLocation?.coordinate.longitude ?? 0)")
//                Text("\(route.endLocation?.coordinate.latitude ?? 0)")
//                Text("\(route.endLocation?.coordinate.longitude ?? 0)")
//
//            }
            Section(header: Text("Route Details")) {
                Text("\(Double(round(route.expectedTravelTime / 60 * 10) / 10), specifier: "%.1f") minutes")
                Text("\(Double(round(route.distance / 1609 * 10) / 10), specifier: "%.1f") miles").foregroundColor(.secondary)
            }
        }
        .task {
            await Route.calculateRouteDetails(route: route)
            try? moc.save()
        }
        .navigationTitle(route.name ?? "")
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
                MapView(moc: _moc, locationManager: _locationManager, route: route)
                    .navigationTitle(route.name ?? "")
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

struct RouteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = DataController().container.viewContext
        let sampleRoute = Route.sampleData(moc: moc)[0]
        let locationManager = LocationManager()
        return RouteDetailView(route: sampleRoute).environmentObject(locationManager)
            .environment(\.managedObjectContext, moc)
    }
}
