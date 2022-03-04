//
//  LocationViewModel.swift
//  Splash
//
//  Created by Shreeya Gad on 3/2/22.
//

import Foundation
import MapKit

struct LocationViewModel: Identifiable, Hashable {
    let id = UUID()
    private var mapItem: MKMapItem
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
    
    var name: String {
        mapItem.name ?? ""
    }
    
    var address: String {
        let postalAddress = mapItem.placemark.postalAddress
        let street = postalAddress?.street ?? ""
        let state = postalAddress?.state ?? ""
        let country = postalAddress?.country ?? ""
        return "\(street), \(state), \(country)"
    }
    
    var coordinate: CLLocationCoordinate2D {
        mapItem.placemark.coordinate
    }
    
    static func compare(lhs: LocationViewModel, rhs: LocationViewModel, center: CLLocationCoordinate2D) -> Bool {
        let latDistance = sqrt(pow(lhs.coordinate.latitude - center.latitude, 2) + pow(lhs.coordinate.longitude - center.longitude, 2))
        let rhsDistance = sqrt(pow(rhs.coordinate.latitude - center.latitude, 2) + pow(rhs.coordinate.longitude - center.longitude, 2))
        return latDistance < rhsDistance
    }
}
