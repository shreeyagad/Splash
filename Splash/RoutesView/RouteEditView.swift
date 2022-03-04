//
//  RouteEditView.swift
//  Splash
//
//  Created by Shreeya Gad on 3/2/22.
//

import SwiftUI

struct RouteEditView: View {
    @Binding var routeData: Route.Data
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        Form {
            Section(header: Text("Route Name")) {
                TextField("Name", text: $routeData.name)
            }
            Section(header: Text("Starting Location")) {
                AutocompleteView(locationName: $routeData.startLocationName, locationAddress: $routeData.startLocationAddress, locationCoordinate: $routeData.startCoordinate)
                    .environmentObject(locationManager)
            }
            Section(header: Text("Ending Location")) {
                AutocompleteView(locationName: $routeData.endLocationName, locationAddress: $routeData.endLocationAddress, locationCoordinate: $routeData.endCoordinate)
                    .environmentObject(locationManager)
            }
        }
    }
}

struct RouteEditView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = DataController().container.viewContext
        let data = Route.sampleData(moc: moc)[0].data
        return RouteEditView(routeData: .constant(data))
    }
}
