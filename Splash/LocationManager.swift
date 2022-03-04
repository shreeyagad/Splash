//
//  LocationManager.swift
//  Splash
//
//  Created by Shreeya Gad on 3/2/22.
//

import Foundation
import MapKit

enum MapDetails {
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
}

final class LocationManager:
        NSObject,
        ObservableObject,
        CLLocationManagerDelegate
        {
    
    var locationManager: CLLocationManager?
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()

    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.startUpdatingLocation()
        }
        else {
            print("Show an alert to turn location services on.")
        }
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else {
            return
        }
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Your location is restricted, likely due to parental restrictions.")
        case .denied:
            print("You have denied this app location permission. Go into Settings to give permission.")
        case .authorizedWhenInUse, .authorizedAlways:
            mapRegion = MKCoordinateRegion(
                center: locationManager.location!.coordinate, span: MapDetails.defaultSpan)
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
}

