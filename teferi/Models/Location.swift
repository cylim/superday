import Foundation
import UIKit
import CoreLocation

class Location
{
    let latitude : Double
    let longitude : Double
    
    init(coordinate: CLLocationCoordinate2D)
    {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    init(latitude : Double, longitude : Double)
    {
        self.latitude = latitude
        self.longitude = longitude
    }
}