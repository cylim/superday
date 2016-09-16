import CoreLocation
import CoreMotion

protocol TimeSlotCreationService
{
    func onNewMotion(_ activity: CMMotionActivity)
 
    func onNewLocation(_ location: CLLocation)
}
