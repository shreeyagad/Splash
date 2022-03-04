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
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        var startingAnnotations: [MKPointAnnotation] = []
        let stop1 = MKPointAnnotation()
        stop1.title = myRoute.startLocation?.name ?? ""
        stop1.subtitle = myRoute.startLocation?.address ?? ""
        stop1.coordinate = myRoute.startLocation?.coordinate ?? CLLocationCoordinate2D()
        let stop2 = MKPointAnnotation()
        stop2.title = theirRoute.startLocation?.name ?? ""
        stop2.subtitle = theirRoute.startLocation?.address ?? ""
        stop2.coordinate = theirRoute.startLocation?.coordinate ?? CLLocationCoordinate2D()
        startingAnnotations.append(contentsOf: [stop1, stop2])
        
        var endingAnnotations: [MKPointAnnotation] = []
        let stop3 = MKPointAnnotation()
        stop3.title = myRoute.endLocation?.name ?? ""
        stop3.subtitle = myRoute.endLocation?.address ?? ""
        stop3.coordinate = myRoute.endLocation?.coordinate ?? CLLocationCoordinate2D()
        let stop4 = MKPointAnnotation()
        stop4.title = theirRoute.endLocation?.name ?? ""
        stop4.subtitle = theirRoute.endLocation?.address ?? ""
        stop4.coordinate = theirRoute.endLocation?.coordinate ?? CLLocationCoordinate2D()
        endingAnnotations.append(contentsOf: [stop3, stop4])
    
        uiView.addAnnotations(startingAnnotations)
        uiView.addAnnotations(endingAnnotations)
        makeRoute(startingAnnotations: startingAnnotations, endingAnnotations: endingAnnotations)
    }
    
    func makeRoute(startingAnnotations: [MKPointAnnotation], endingAnnotations: [MKPointAnnotation]) {
        let stop1 = MKPlacemark(coordinate: startingAnnotations[0].coordinate)
        let stop2 = MKPlacemark(coordinate: startingAnnotations[1].coordinate)
        let stop3 = MKPlacemark(coordinate: endingAnnotations[0].coordinate)
        let stop4 = MKPlacemark(coordinate: endingAnnotations[1].coordinate)
        
        var request1 = MKDirections.Request()
        var request2 = MKDirections.Request()
        var request3 = MKDirections.Request()
        if isDriver {
            // route 1: stop 2 -> stop 1 -> stop 3 -> stop 4
            // 3 requests
            
            request1.source = MKMapItem(placemark: stop1)
            request1.destination = MKMapItem(placemark: stop2)
            request1.requestsAlternateRoutes = true
            request1.transportType = .automobile
            
            request2.source = MKMapItem(placemark: stop2)
            request2.destination = MKMapItem(placemark: stop4)
            request2.requestsAlternateRoutes = true
            request2.transportType = .automobile
            
            request3.source = MKMapItem(placemark: stop4)
            request3.destination = MKMapItem(placemark: stop3)
            request3.requestsAlternateRoutes = true
            request3.transportType = .automobile
        }
        
        else {
        // route 2: stop 1 -> stop 2 -> stop 4 -> stop 3
        // 3 requests
            request1.source = MKMapItem(placemark: stop2)
            request1.destination = MKMapItem(placemark: stop1)
            request1.requestsAlternateRoutes = true
            request1.transportType = .automobile
            
            request2.source = MKMapItem(placemark: stop1)
            request2.destination = MKMapItem(placemark: stop3)
            request2.requestsAlternateRoutes = true
            request2.transportType = .automobile
            
            request3.source = MKMapItem(placemark: stop3)
            request3.destination = MKMapItem(placemark: stop4)
            request3.requestsAlternateRoutes = true
            request3.transportType = .automobile
            
        }
        
        var directions1 = MKDirections(request: request1)
        var directions2 = MKDirections(request: request2)
        var directions3 = MKDirections(request: request3)
        
        let directions = [directions1, directions2, directions3]
        
        for direction in directions {
            direction.calculate { response, error in
                guard let wrappedResponse = response else { return }
                
                //for getting just one route
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
