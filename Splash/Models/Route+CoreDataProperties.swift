//
//  Route+CoreDataProperties.swift
//  Splash
//
//  Created by Shreeya Gad on 3/2/22.
//
//

import Foundation
import CoreData
import MapKit

extension Route {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Route> {
        return NSFetchRequest<Route>(entityName: "Route")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var username: String?
    @NSManaged public var distance: Double
    @NSManaged public var expectedTravelTime: Double
    @NSManaged public var startLocation: Location?
    @NSManaged public var endLocation: Location?

}

extension Route : Identifiable {
    struct Data {
        var name: String = ""
        var username: String = ""
        var startLocationName: String = ""
        var endLocationName: String = ""
        var startLocationAddress: String = ""
        var endLocationAddress: String = ""
        var startCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
        var endCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    }

    var data: Data {
        return Data(
            name: name ?? "",
            username: username ?? "",
            startLocationName: startLocation?.name ?? "",
            endLocationName: endLocation?.name ?? "",
            startLocationAddress: startLocation?.address ?? "",
            endLocationAddress: endLocation?.address ?? "",
            startCoordinate: CLLocationCoordinate2D(latitude: startLocation?.latitude ?? 0, longitude: startLocation?.longitude ?? 0),
            endCoordinate: CLLocationCoordinate2D(latitude: endLocation?.latitude ?? 0, longitude: endLocation?.longitude ?? 0)
        )
    }

    static func addRoute(data: Data, moc: NSManagedObjectContext) -> Route {
        let newRoute = Route(context: moc)
        newRoute.id = UUID()
        newRoute.name = data.name
        newRoute.username = data.username
        
        let startLocation = Location(context: moc)
        let endLocation = Location(context: moc)
        
        startLocation.name = data.startLocationName
        startLocation.address = data.startLocationAddress
        
        endLocation.name = data.endLocationName
        endLocation.address = data.endLocationAddress
        
        startLocation.latitude = data.startCoordinate.latitude
        startLocation.longitude = data.startCoordinate.longitude
        
        endLocation.latitude = data.endCoordinate.latitude
        endLocation.longitude = data.endCoordinate.longitude
        
        newRoute.startLocation = startLocation
        newRoute.endLocation = endLocation
        
        return newRoute
    }
    
    static func calculateRouteDetails(route: Route) async {
        let request = MKDirections.Request()
        let startingPlacemark = MKPlacemark(coordinate: route.startLocation?.coordinate ?? CLLocationCoordinate2D())
        let endingPlacemark = MKPlacemark(coordinate: route.endLocation?.coordinate ?? CLLocationCoordinate2D())
        
        request.source = MKMapItem(placemark: startingPlacemark)
        request.destination = MKMapItem(placemark: endingPlacemark)
        request.requestsAlternateRoutes = true
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let wrappedResponse = response else { return }
            if let routeResponse = wrappedResponse.routes.first {
                route.distance = routeResponse.distance
                route.expectedTravelTime = routeResponse.expectedTravelTime
            }
        }
    }
}

extension Route {
    static func sampleData(moc: NSManagedObjectContext) -> [Route] {
        var routeData = Route.Data()
        routeData.name = "Work"
        routeData.username = "Lisa Simpson"
        routeData.startCoordinate = CLLocationCoordinate2D(latitude: 37.368612, longitude: -122.035588)
        routeData.endCoordinate = CLLocationCoordinate2D(latitude: 37.422338, longitude: -122.084370)
        routeData.startLocationName = "Starbucks"
        routeData.startLocationAddress = "460 N Mathilda Ave, CA, United States"
        routeData.endLocationName = "Google"
        routeData.endLocationAddress = "1600 Amphitheatre Pkwy, CA, United States"
        let sampleRoute = Route.addRoute(data: routeData, moc: moc)
        
        var routeData2 = Route.Data()
        routeData2.name = "Coffee"
        routeData2.username = "Lisa Simpson"
        routeData2.startCoordinate = CLLocationCoordinate2D(latitude: 37.368612, longitude: -122.035588)
        routeData2.endCoordinate = CLLocationCoordinate2D(latitude: 37.422338, longitude: -122.084370)
        routeData2.startLocationName = "Safeway"
        routeData2.startLocationAddress = "460 N Mathilda Ave, CA, United States"
        routeData2.endLocationName = "1 oz Coffee"
        routeData2.endLocationAddress = "1600 Amphitheatre Pkwy, CA, United States"
        let sampleRoute2 = Route.addRoute(data: routeData2, moc: moc)
        
        var routeData3 = Route.Data()
        routeData3.name = "Groceries"
        routeData3.username = "Noah Cyrus"
        routeData3.startCoordinate = CLLocationCoordinate2D(latitude: 37.368612, longitude: -122.035588)
        routeData3.endCoordinate = CLLocationCoordinate2D(latitude: 37.422338, longitude: -122.084370)
        routeData3.startLocationName = "Fremont High School"
        routeData3.startLocationAddress = "460 N Mathilda Ave, CA, United States"
        routeData3.endLocationName = "Trader Joe's"
        routeData3.endLocationAddress = "1600 Amphitheatre Pkwy, CA, United States"
        let sampleRoute3 = Route.addRoute(data: routeData3, moc: moc)
        
        return [sampleRoute, sampleRoute2, sampleRoute3]
    }
}
