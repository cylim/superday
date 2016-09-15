import CoreLocation
import CoreMotion
import Foundation

class DefaultTimeSlotCreationService : TimeSlotCreationService
{
    private enum CurrentMotion
    {
        case Stationary
        case Moving
    }
    
    // MARK: Fields
    private let travelThreshold = 100.0
    private let persistencyService : PersistencyService
    
    private var isTraveling = false
    private var traveledDistance = 0.0
    private var stopTimer : NSTimer? = nil
    private var firstLocation : CLLocation? = nil
    
    private var currentMotion = CurrentMotion.Stationary
    
    // MARK: Init
    init(persistencyService: PersistencyService)
    {
        self.persistencyService = persistencyService
    }
    
    // TimeSlotCreationService
    func onNewMotion(activity: CMMotionActivity)
    {
        currentMotion = activity.stationary ? .Stationary : .Moving
    }
    
    func onNewLocation(location: CLLocation)
    {
        //If no location was previously set, this is our starting point
        if firstLocation == nil
        {
            firstLocation = location
            return
        }
        
        let startLocation = firstLocation!
        
        if isTraveling
        {
            // User is still traveling
            guard location.speed > 0 else
            {
                stopTimer?.invalidate()
                stopTimer = nil
                return
            }
            
            //Timer not previously set
            guard stopTimer != nil else
            {
                // Since the user stopped, we wait for 10 minutes. If he does not move again, we end the commute and begin a new one.
                stopTimer = NSTimer.scheduledTimerWithTimeInterval(600, target: self, selector: #selector(stopTraveling), userInfo: nil, repeats: false)
                return
            }
        }
        else
        {
            let distance = startLocation.distanceFromLocation(location)
            traveledDistance += distance
            
            // User traveled over n meters
            guard traveledDistance > travelThreshold else { return }
            
            isTraveling = true
            let timeSlot = TimeSlot()
            timeSlot.category = .Commute
            persistencyService.addNewTimeSlot(timeSlot)
        }
    }
    
    @objc private func stopTraveling()
    {
        isTraveling = false
        firstLocation = nil
        traveledDistance = 0.0
        
        let timeSlot = TimeSlot()
        persistencyService.addNewTimeSlot(timeSlot)
    }
}