//
//  MapView.swift
//  Splash
//
//  Created by Shreeya Gad on 3/2/22.
//

import SwiftUI
import MapKit
import CoreData

struct MapView: UIViewRepresentable {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var locationManager: LocationManager
    @ObservedObject var route: Route
    
    let myMap = MKMapView()
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        let startingAnnotation = MKPointAnnotation()
        startingAnnotation.title = route.startLocation?.name ?? ""
        startingAnnotation.subtitle = route.startLocation?.address ?? ""
        startingAnnotation.coordinate = route.startLocation?.coordinate ?? CLLocationCoordinate2D()
        
        let endingAnnotation = MKPointAnnotation()
        endingAnnotation.title = route.endLocation?.name ?? ""
        endingAnnotation.subtitle = route.endLocation?.address ?? ""
        endingAnnotation.coordinate = route.endLocation?.coordinate ?? CLLocationCoordinate2D()
        uiView.addAnnotations([startingAnnotation, endingAnnotation])
        makeRoute(startingAnnotation: startingAnnotation, endingAnnotation: endingAnnotation)
    }
    
    func makeRoute(startingAnnotation: MKPointAnnotation, endingAnnotation: MKPointAnnotation) {
        let request = MKDirections.Request()
        let startingPlacemark = MKPlacemark(coordinate: startingAnnotation.coordinate)
        let endingPlacemark = MKPlacemark(coordinate: endingAnnotation.coordinate)
        request.source = MKMapItem(placemark: startingPlacemark)
        request.destination = MKMapItem(placemark: endingPlacemark)
        request.requestsAlternateRoutes = true
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let wrappedResponse = response else { return }
            
            //for getting just one route
            if let routeResponse = wrappedResponse.routes.first {
                myMap.addOverlay(routeResponse.polyline)
                myMap.setVisibleMapRect(routeResponse.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 80.0, left: 40.0, bottom: 100.0, right: 40.0), animated: true)
            }
        }
    }
    
    func makeUIView(context: Context) -> MKMapView {
        myMap.delegate = context.coordinator
        let center = route.startLocation?.coordinate ?? locationManager.mapRegion.center
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
        var parent: MapView
        
        init(_ parent: MapView) {
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
            renderer.strokeColor = UIColor.systemRed
            renderer.lineWidth = 4.0
            return renderer
        }
    }
}
