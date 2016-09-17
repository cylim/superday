import CoreLocation
import CoreMotion
import Foundation

class DefaultTimeSlotCreationService : TimeSlotCreationService
{
    // MARK: Constants
    private let travelThreshold = 100.0
    private let isTravelingKey = "isTravelingKey"
    private let firstLocationFile = "firstLocationFile"
    
    // MARK: Fields
    private let persistencyService : PersistencyService
    
    private var isTraveling : Bool
    {
        didSet
        {
            UserDefaults.standard.setValue(isTraveling, forKey: isTravelingKey)
        }
    }
    
    private var firstLocation : CLLocation? = nil
    
    private var stopTimer : Timer? = nil
    
    // MARK: Init
    init(persistencyService: PersistencyService)
    {
        self.persistencyService = persistencyService
        
        self.isTraveling = UserDefaults.standard.bool(forKey: isTravelingKey)
    }
    
    // TimeSlotCreationService
    func onNewMotion(_ activity: CMMotionActivity)
    {
        //TODO: Consider motion events when creating new TimeSlots
    }
    
    func onNewLocation(_ location: CLLocation)
    {
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
                stopTimer = Timer.scheduledTimer(timeInterval: 600 - location.timestamp.timeIntervalSinceNow, target: self, selector: #selector(stopTraveling), userInfo: nil, repeats: false)
                return
            }
        }
        else
        {
            //If no location was previously set, this is our starting point
            if firstLocation == nil
            {
                firstLocation = location
                return
            }
            
            let startLocation = firstLocation!
            
            //TODO: This considers travels in a straight line. We should make this smarter later
            let distance = startLocation.distance(from: location)
            
            // User traveled over n meters
            guard distance > travelThreshold else { return }
            
            isTraveling = true
            let timeSlot = TimeSlot(category: .Commute)
            
            if !persistencyService.addNewTimeSlot(timeSlot)
            {
                //TODO: Recover from failure
            }
        }
    }
    
    @objc private func stopTraveling()
    {
        isTraveling = false
        firstLocation = nil
        
        let timeSlot = TimeSlot()
        persistencyService.addNewTimeSlot(timeSlot)
    }
}
