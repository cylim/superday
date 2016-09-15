import CoreLocation
import CoreMotion

protocol TimeSlotCreationService
{
    func onNewMotion(activity: CMMotionActivity)
 
    func onNewLocation(location: CLLocation)
}