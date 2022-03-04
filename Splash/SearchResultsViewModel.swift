//
//  SearchResultsViewModel.swift
//  Splash
//
//  Created by Shreeya Gad on 3/2/22.
//

import Foundation
import MapKit
import Contacts

@MainActor
class SearchResultsViewModel: ObservableObject {
    
    @Published var locations = [LocationViewModel]()
    
    func search(text: String, region: MKCoordinateRegion) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
        searchRequest.region = region
        
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown Error")")
                return
            }
            self.locations = response.mapItems.map(LocationViewModel.init)
        }
    }
}

