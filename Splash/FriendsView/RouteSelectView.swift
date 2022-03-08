//
//  RouteSelectView.swift
//  Splash
//
//  Created by Shreeya Gad on 3/3/22.
//

import SwiftUI
import CoreData
import MapKit

struct RouteSelectView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var locationManager: LocationManager
    @ObservedObject var theirRoute: Route
    
    @Binding var isPresentingCompareView: Bool
    @State private var isPresentingMapView: Bool = false
    
    @State private var isDriver: Bool = true
    @State private var isMapDriver: Bool = true
    
    @State private var myRoute: Route = Route()
    @State private var selectedRoute: Bool = false
    
    @State private var iDriveTime: Double = 0
    @State private var iDriveDistance: Double = 0
    
    @State private var theyDriveTime: Double = 0
    @State private var theyDriveDistance: Double = 0
    
    @State private var detourTime: Double = 0
    @State private var detourDistance: Double = 0
    
    func calculateDetourTime(isDriver: Bool) -> Double {
        if selectedRoute == true {
            var temp = 0.0
            if isDriver {
                
                temp = (myRoute.expectedTravelTime + theirRoute.expectedTravelTime) - iDriveTime
            }
            else {
                temp = (myRoute.expectedTravelTime + theirRoute.expectedTravelTime) - theyDriveTime
            }
            return Double(round((temp / 60 * 10) / 10))
        }
        else {
            return 0.0
        }
    }
    
    func calculateDetourDistance(isDriver: Bool) -> Double {
        if selectedRoute {
            var temp = 0.0
            if isDriver {
                temp = (myRoute.distance + theirRoute.distance) - iDriveDistance
            }
            else {
                temp = (myRoute.distance + theirRoute.distance) - theyDriveDistance
            }
            return Double(round((temp / 1609 * 10) / 10))
        }
        else {
            return 0.0
        }
    }
    
    // helper function for calculateTimesAndDistances
    func createDirections(start: MKPlacemark, end: MKPlacemark) -> MKDirections {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: start)
        request.destination = MKMapItem(placemark: end)
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        return MKDirections(request: request)
    }
    
    func calculateTimesAndDistances() async {
        guard let myStartLocation = myRoute.startLocation?.coordinate else {return}
        guard let theirStartLocation = theirRoute.startLocation?.coordinate else {return}
        guard let myEndLocation = myRoute.endLocation?.coordinate else {return}
        guard let theirEndLocation = theirRoute.endLocation?.coordinate else {return}
        
        let stop1 = MKPlacemark(coordinate: myStartLocation)
        let stop2 = MKPlacemark(coordinate: theirStartLocation)
        let stop3 = MKPlacemark(coordinate: myEndLocation)
        let stop4 = MKPlacemark(coordinate: theirEndLocation)
        
        // route 1: stop 1 -> stop 2 -> stop 4 -> stop 3
        let directions1 = createDirections(start: stop1, end: stop2)
        let directions2 = createDirections(start: stop2, end: stop4)
        let directions3 = createDirections(start: stop4, end: stop3)
        
        // route 2: stop 2 -> stop 1 -> stop 3 -> stop 4
        let directions4 = createDirections(start: stop2, end: stop1)
        let directions5 = createDirections(start: stop1, end: stop3)
        let directions6 = createDirections(start: stop3, end: stop4)
        
        let directionsIDrive = [directions1, directions2, directions3]
        let directionsTheyDrive = [directions4, directions5, directions6]
        
        iDriveTime = 0
        iDriveDistance = 0
        for direction in directionsIDrive {
            direction.calculate { response, error in
                guard let wrappedResponse = response else { return }
                if let routeResponse = wrappedResponse.routes.first {
                    iDriveTime += routeResponse.expectedTravelTime
                    iDriveDistance += routeResponse.distance
                }
            }
        }
        theyDriveTime = 0
        theyDriveDistance = 0
        for direction in directionsTheyDrive {
            direction.calculate { response, error in
                guard let wrappedResponse = response else { return }
                if let routeResponse = wrappedResponse.routes.first {
                    theyDriveTime += routeResponse.expectedTravelTime
                    theyDriveDistance += routeResponse.distance
                }
            }
        }
    }
    
    var body: some View {
        return Form {
            Section(header: Text("Their Route")) {
                Text(theirRoute.name ?? "")
            }
            Section(header: Text("Choose Route")) {
                RouteSelectorView(myRoute: $myRoute).environment(\.managedObjectContext, moc)
            }
            Section(header: Text("Route Details")) {
                Toggle(isOn: $isDriver){
                    if isDriver {
                        Text("I'm driving")
                    }
                    else {
                        Text("They're driving")
                    }
                    }
                if isDriver {
                    Text("\(Double(round(iDriveTime / 60 * 10) / 10), specifier: "%.1f") minutes")
                    Text("\(Double(round(iDriveDistance / 1609 * 10) / 10), specifier: "%.1f") miles").foregroundColor(.secondary)
                }
                else {
                    Text("\(Double(round(theyDriveTime / 60 * 10) / 10), specifier: "%.1f") minutes")
                    Text("\(Double(round(theyDriveDistance / 1609 * 10) / 10), specifier: "%.1f") miles").foregroundColor(.secondary)
                }
            }
            Section(header: Text("You can save")) {
                if selectedRoute {
                    if isDriver {
                        Text("4.6 minutes of driving")
                        Text("6.3 miles of driving")
                        Text("\(6.3 * 404 / 1000, specifier: "%.1f") kg of CO2").foregroundColor(.green)
                    }
                    else {
                        Text("4.8 minutes of driving")
                        Text("3.8 miles of driving")
                        Text("\(3.8 * 404 / 1000, specifier: "%.1f") kg of CO2").foregroundColor(.green)
                    }
                }
                else {
                    Text("0.0 minutes of driving")
                    Text("0.0 miles of driving")
                    Text("0.0 kg of CO2").foregroundColor(.green)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    isPresentingCompareView = false
                }) {
                    Text("Dismiss")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    isPresentingMapView = true
                }) {
                    Label("", systemImage: "map")
                }
            }
        }
        .onChange(of: myRoute) { myRoute in
            async {
                selectedRoute = true
                isPresentingMapView = true
                await calculateTimesAndDistances()
                detourTime = calculateDetourTime(isDriver: isDriver)
                detourDistance = calculateDetourDistance(isDriver: isDriver)
            }
        }
        .sheet(isPresented: $isPresentingMapView) {
            NavigationView {
                VStack {
                    Toggle(isOn: $isMapDriver){
                        if isMapDriver {
                            Text("I'm driving")
                        }
                        else {
                            Text("They're driving")
                        }
                    }.padding(.horizontal)
                    if isMapDriver {
                        MapDetourView(
                            moc: _moc,
                            locationManager: _locationManager,
                            myRoute: myRoute,
                            theirRoute: theirRoute,
                            isDriver: true
                        )
                    }
                    else {
                        MapDetourView(
                            moc: _moc,
                            locationManager: _locationManager,
                            myRoute: myRoute,
                            theirRoute: theirRoute,
                            isDriver: false
                        )
                    }
                }
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
