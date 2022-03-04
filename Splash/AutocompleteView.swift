//
//  AutocompleteView.swift
//  Splash
//
//  Created by Shreeya Gad on 3/2/22.
//

import SwiftUI
import MapKit

struct AutocompleteView: View {
    @EnvironmentObject var locationManager: LocationManager
    @StateObject private var viewModel: SearchResultsViewModel = SearchResultsViewModel()
    
    @Binding var locationName: String
    @Binding var locationAddress: String
    @Binding var locationCoordinate: CLLocationCoordinate2D
    
    @State private var selectedLocation: LocationViewModel? = nil
    @State private var locationNameTapped: Bool = true
    
    var body: some View {
        VStack(alignment: .leading) {
            if (locationNameTapped) {
                TextField("Name", text: $locationName)
                if (viewModel.locations.count > 0) {
                    Divider()
                    ScrollView {
                        ForEach(0..<viewModel.locations.count, id: \.self) { p in
                            LocationSearchResultView(
                            selectedLocation: $selectedLocation, location: viewModel.locations[p], notLastLocation:
                                (p < viewModel.locations.count-1))
                        }
                    }.frame(maxHeight: 200)
                    Spacer()
                }
            }
            else {
                if (locationName == "") {Text("Name").foregroundColor(.secondary)}
                else {
                    Text(locationName)
                    Divider()
                    Text(locationAddress).foregroundColor(.secondary)
                }
            }
        }
        .onTapGesture {
            locationNameTapped = true
            viewModel.search(text: locationName, region: locationManager.mapRegion)
            
        }
        .onChange(of: locationName, perform: { searchText in
            viewModel.search(
                text: searchText,
                region: locationManager.mapRegion)
        })
        .onChange(of: selectedLocation, perform: {
            location in
            guard let wrappedLocation = location else {
                return
            }
            locationName = wrappedLocation.name
            locationAddress = wrappedLocation.address
            locationCoordinate = wrappedLocation.coordinate
            locationNameTapped = false
        })
    }
}

struct AutocompleteView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = DataController().container.viewContext
        let sampleLocation = Location.sampleData(moc: moc)[0]
        return AutocompleteView(locationName: .constant(sampleLocation.name ?? ""), locationAddress: .constant(sampleLocation.address ?? ""), locationCoordinate: .constant(sampleLocation.coordinate))
    }
}
