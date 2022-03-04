//
//  LocationSearchResultView.swift
//  Splash
//
//  Created by Shreeya Gad on 3/2/22.
//

import SwiftUI
import MapKit
import Contacts

struct LocationSearchResultView: View {
    @Binding var selectedLocation: LocationViewModel?
    var location: LocationViewModel
    var notLastLocation: Bool
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(location.name)
                    Text(location.address).font(.caption2).foregroundColor(.gray)
                }
                Spacer()
            }
            if (notLastLocation)
            { Divider() }
        }.onTapGesture {
            selectedLocation = location
        }
    }
}

struct LocationSearchResultView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchResultView(
            selectedLocation: .constant(LocationViewModel(mapItem: MKMapItem())),
            location: LocationViewModel(mapItem: MKMapItem()),
            notLastLocation: true)
    }
}
