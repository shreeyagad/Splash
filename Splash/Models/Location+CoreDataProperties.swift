//
//  Location+CoreDataProperties.swift
//  Splash
//
//  Created by Shreeya Gad on 3/2/22.
//
//

import Foundation
import CoreData
import MapKit


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var address: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var startLocationToRoute: NSSet?
    @NSManaged public var endLocationToRoute: NSSet?
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

}

// MARK: Generated accessors for startLocationToRoute
extension Location {

    @objc(addStartLocationToRouteObject:)
    @NSManaged public func addToStartLocationToRoute(_ value: Route)

    @objc(removeStartLocationToRouteObject:)
    @NSManaged public func removeFromStartLocationToRoute(_ value: Route)

    @objc(addStartLocationToRoute:)
    @NSManaged public func addToStartLocationToRoute(_ values: NSSet)

    @objc(removeStartLocationToRoute:)
    @NSManaged public func removeFromStartLocationToRoute(_ values: NSSet)

}

// MARK: Generated accessors for endLocationToRoute
extension Location {

    @objc(addEndLocationToRouteObject:)
    @NSManaged public func addToEndLocationToRoute(_ value: Route)

    @objc(removeEndLocationToRouteObject:)
    @NSManaged public func removeFromEndLocationToRoute(_ value: Route)

    @objc(addEndLocationToRoute:)
    @NSManaged public func addToEndLocationToRoute(_ values: NSSet)

    @objc(removeEndLocationToRoute:)
    @NSManaged public func removeFromEndLocationToRoute(_ values: NSSet)
}

extension Location {
    static func sampleData(moc: NSManagedObjectContext) -> [Location] {
        let sampleLocation = Location(context: moc)
        sampleLocation.id = UUID()
        sampleLocation.name = "Cho Dang Gol"
        sampleLocation.address = "55 W 35th St, New York, NY 10001"
        sampleLocation.latitude = 0
        sampleLocation.longitude = 0
        return [sampleLocation]
    }
}
