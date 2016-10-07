import CoreLocation
import CoreMotion
import UIKit
import Foundation

/// Default implementation of the TimeSlotCreationService.
class DefaultTimeSlotCreationService : TimeSlotCreationService
{
    // MARK: Fields
    private let loggingService : LoggingService
    private let persistencyService : PersistencyService
    private let notificationService : NotificationService
    
    ///Defines whether the user is currently traveling or not.
    private var isTraveling : Bool
    {
        didSet
        {
            loggingService.log(withLogLevel: .debug, message: "User is \(isTraveling ? "" : "not" ) traveling")
            UserDefaults.standard.setValue(isTraveling, forKey: Constants.isTravelingKey)
        }
    }
    
    //TODO: This needs to be persisted for more accuracy.
    private var firstLocation : CLLocation? = nil
    
    ///Timer that controls when the current TimeSlot needs to end.
    private var stopTimer : Timer? = nil
    
    //MARK: Init
    init(persistencyService: PersistencyService, loggingService: LoggingService, notificationService: NotificationService)
    {
        self.loggingService = loggingService
        self.persistencyService = persistencyService
        self.notificationService = notificationService
        self.isTraveling = UserDefaults.standard.bool(forKey: Constants.isTravelingKey)
        
        loggingService.log(withLogLevel: .verbose, message: "User is \(isTraveling ? "" : "not" ) traveling")
    }
    
    //MARK:  TimeSlotCreationService implementation
    func onNewMotion(_ activity: CMMotionActivity)
    {
        //TODO: Consider motion events when creating new TimeSlots
        loggingService.log(withLogLevel: .debug, message: "Received new motion")
    }
    
    func onNewLocation(_ location: CLLocation)
    {
        if isTraveling
        {
            // User is still traveling
            guard location.speed > 0 else
            {
                loggingService.log(withLogLevel: .debug, message: "Received new position with speed \(location.speed)")
                
                stopTimer?.invalidate()
                stopTimer = nil
                return
            }
            
            //Timer not previously set
            guard stopTimer != nil else
            {
                loggingService.log(withLogLevel: .debug, message: "User stopped. Starting timer.")
                
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
            guard distance > Constants.distanceFilter else { return }
            
            loggingService.log(withLogLevel: .debug, message: "User traveled \(distance) meters. Creating new TimeSlot.")
            
            isTraveling = true
            let timeSlot = TimeSlot(category: .commute)
            
            if !persistencyService.addNewTimeSlot(timeSlot)
            {
                //TODO: Recover from failure
                loggingService.log(withLogLevel: .debug, message: "TimeSlotCreationService failed to create a new Commute TimeSlot.")
            }
        }
    }
    
    @objc private func stopTraveling()
    {
        isTraveling = false
        firstLocation = nil
        
        loggingService.log(withLogLevel: .debug, message: "No movement detected for 10 minutes. Creating a new Unknown TimeSlot")
        
        let timeSlot = TimeSlot()
        if !persistencyService.addNewTimeSlot(timeSlot)
        {
            //TODO: Recover from creation failure
            loggingService.log(withLogLevel: .debug, message: "TimeSlotCreationService failed to create a new empty TimeSlot.")
        }
    }
}
