import CoreLocation
import CoreMotion

///Service that tries to create the TimeSlots automatically using sensor data
protocol TimeSlotCreationService
{
    //MARK: Methods
    
    /**
     Called when a new Motion Event happens.
     
     - Parameter activity: Contains the motion activity information.
     */
    func onNewMotion(_ activity: CMMotionActivity)
    
    /**
     Called when the user's location changes.
     
     - Parameter location: contains the user's current location.
     */
    func onNewLocation(_ location: CLLocation)
}
