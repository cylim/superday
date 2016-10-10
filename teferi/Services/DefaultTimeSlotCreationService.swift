import CoreLocation
import CoreMotion
import UIKit
import Foundation

/// Default implementation of the TimeSlotCreationService.
class DefaultTimeSlotCreationService : TimeSlotCreationService
{
    // MARK: Fields
    private let loggingService : LoggingService
    private var settingsService : SettingsService
    private let persistencyService : PersistencyService
    private let notificationService : NotificationService
    
    //MARK: Init
    init(settingsService: SettingsService, persistencyService: PersistencyService, loggingService: LoggingService, notificationService: NotificationService)
    {
        self.loggingService = loggingService
        self.settingsService = settingsService
        self.persistencyService = persistencyService
        self.notificationService = notificationService
    }
    
    //MARK:  TimeSlotCreationService implementation
    func onNewMotion(_ activity: CMMotionActivity)
    {
        //TODO: Consider motion events when creating new TimeSlots
        loggingService.log(withLogLevel: .debug, message: "Received new motion")
    }
    
    func onNewLocation(_ location: CLLocation)
    {
        let currentLocationTime = location.timestamp
        let previousTime = settingsService.lastLocationDate
        
        settingsService.setLastLocationDate(currentLocationTime)
        
        guard let previousLocationTime = previousTime else { return }
        
        let currentTimeSlot = persistencyService.getLastTimeSlot()
        
        let difference = currentLocationTime.timeIntervalSince(previousLocationTime)
        if (difference / 60) < 25.0
        {
            guard currentTimeSlot.category != .unknown else { return }
            
            persistencyService.updateTimeSlot(currentTimeSlot, withCategory: .commute)
        }
        else
        {
            if currentTimeSlot.startTime != previousLocationTime
            {
                let intervalTimeSlot = TimeSlot(withStartDate: previousLocationTime)
                persistencyService.addNewTimeSlot(intervalTimeSlot)
            }
            
            let newTimeSlot = TimeSlot(withStartDate: currentLocationTime)
            persistencyService.addNewTimeSlot(newTimeSlot)
        }
    }
}
