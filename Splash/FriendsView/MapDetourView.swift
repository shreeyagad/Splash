//
//  MapDetourView.swift
//  Splash
//
//  Created by Shreeya Gad on 3/2/22.
//

import SwiftUI
import MapKit
import CoreData

struct MapDetourView: UIViewRepresentable {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var locationManager: LocationManager
    @ObservedObject var myRoute: Route
    @ObservedObject var theirRoute: Route

    var isDriver: Bool
    
    let myMap = MKMapView()
    
    // helper function for updateUIView
    func createAnnotationFromRoute(route: Route, start: Bool = true) -> MKPointAnnotation {
        let stop = MKPointAnnotation()
        let location: Location?
        if start {
            location = route.startLocation
        }
        else {
            location = route.endLocation
        }
        stop.title = location?.name ?? ""
        stop.subtitle = location?.address ?? ""
        stop.coordinate = location?.coordinate ?? CLLocationCoordinate2D()
        return stop
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        var startingAnnotations: [MKPointAnnotation] = []
        let stop1 = createAnnotationFromRoute(route: myRoute)
        let stop2 = createAnnotationFromRoute(route: theirRoute)
        startingAnnotations.append(contentsOf: [stop1, stop2])
        
        var endingAnnotations: [MKPointAnnotation] = []
        let stop3 = createAnnotationFromRoute(route: myRoute, start: false)
        let stop4 = createAnnotationFromRoute(route: myRoute, start: false)
        endingAnnotations.append(contentsOf: [stop3, stop4])
    
        uiView.addAnnotations(startingAnnotations)
        uiView.addAnnotations(endingAnnotations)
        makeRoute(startingAnnotations: startingAnnotations, endingAnnotations: endingAnnotations)
    }
    
    // helper function for makeRoute
    func createDirections(start: MKPlacemark, end: MKPlacemark) -> MKDirections {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: start)
        request.destination = MKMapItem(placemark: end)
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        return MKDirections(request: request)
    }
    
    func makeRoute(startingAnnotations: [MKPointAnnotation], endingAnnotations: [MKPointAnnotation]) {
        let stop1 = MKPlacemark(coordinate: startingAnnotations[0].coordinate)
        let stop2 = MKPlacemark(coordinate: startingAnnotations[1].coordinate)
        let stop3 = MKPlacemark(coordinate: endingAnnotations[0].coordinate)
        let stop4 = MKPlacemark(coordinate: endingAnnotations[1].coordinate)
        var directions: [MKDirections] = []
        
        if isDriver {
            // route 1: stop 2 -> stop 1 -> stop 3 -> stop 4
            let directions1 = createDirections(start: stop2, end: stop1)
            let directions2 = createDirections(start: stop1, end: stop3)
            let directions3 = createDirections(start: stop3, end: stop4)
            directions = [directions1, directions2, directions3]
        }
        
        else {
            // route 2: stop 1 -> stop 2 -> stop 4 -> stop 3
            let directions1 = createDirections(start: stop1, end: stop2)
            let directions2 = createDirections(start: stop2, end: stop4)
            let directions3 = createDirections(start: stop4, end: stop3)
            directions = [directions1, directions2, directions3]
        }
        
        for direction in directions {
            direction.calculate { response, error in
                guard let wrappedResponse = response else { return }
                if let routeResponse = wrappedResponse.routes.first {
                    if isDriver {
                        routeResponse.polyline.title = "myRoute"
                    }
                    myMap.addOverlay(routeResponse.polyline)
                    myMap.setVisibleMapRect(routeResponse.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 100.0, left: 50.0, bottom: 100.0, right: 50.0), animated: true)
                }
            }
        }
    }
    
    
    func makeUIView(context: Context) -> MKMapView {
        myMap.delegate = context.coordinator
        let center = theirRoute.startLocation?.coordinate ?? locationManager.mapRegion.center
        myMap.region = MKCoordinateRegion(center: center, span: MapDetails.defaultSpan)
        myMap.showsUserLocation = true
        myMap.userTrackingMode = MKUserTrackingMode.follow
        return myMap
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator:
        NSObject,
        MKMapViewDelegate {
        var parent: MapDetourView
        
        init(_ parent: MapDetourView) {
            self.parent = parent
            super.init()
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if (annotation.title == "My Location") {return nil}
            
            let identifier = "Placemark"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation,
                reuseIdentifier: identifier)
                
                annotationView?.canShowCallout = true
                let callButton = UIButton(type: .detailDisclosure)
                annotationView?.rightCalloutAccessoryView = callButton
                annotationView?.sizeToFit()
                annotationView?.isHighlighted = true
            }
            else {
                annotationView?.annotation = annotation as? MKPointAnnotation
            }
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            //
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            if overlay.title == "myRoute" {
                renderer.strokeColor = UIColor.systemRed
            }
            else {
                renderer.strokeColor = UIColor.systemBlue
            }
            renderer.lineWidth = 4.0
            return renderer
        }
    }
}
