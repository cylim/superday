import CoreLocation
import CoreMotion
import UIKit
import Foundation

/// Default implementation of the TrackingService.
class DefaultTrackingService : TrackingService
{
    // MARK: Fields
    private let notificationBody = "NotificationBody".translate()
    private let notificationTitle = "NotificationTitle".translate()
    private let notificationTimeout = TimeInterval(20 * 60)
    
    private let loggingService : LoggingService
    private let settingsService : SettingsService
    private let timeSlotService : TimeSlotService
    private let smartGuessService : SmartGuessService
    private let notificationService : NotificationService
    
    private var isOnBackground = false
    
    //MARK: Init
    init(loggingService: LoggingService,
         settingsService: SettingsService,
         timeSlotService: TimeSlotService,
         smartGuessService: SmartGuessService,
         notificationService: NotificationService)
    {
        self.loggingService = loggingService
        self.settingsService = settingsService
        self.timeSlotService = timeSlotService
        self.smartGuessService = smartGuessService
        self.notificationService = notificationService
    }
    
    //MARK:  TrackingService implementation
    func onLocation(_ location: CLLocation)
    {
        guard self.isOnBackground else { return }
        
        guard let previousLocation = self.settingsService.lastLocation else
        {
            self.settingsService.setLastLocation(location)
            return
        }
        
        guard location.timestamp > previousLocation.timestamp else { return }
        
        self.settingsService.setLastLocation(location)
        
        let currentTimeSlot = self.timeSlotService.getLast()
        
        let difference = location.timestamp.timeIntervalSince(previousLocation.timestamp)
        if (difference / 60) < 25.0
        {
            //If it was smart guessed and we detect movement, we got it wrong and override it with a commute
            guard currentTimeSlot.category == .unknown || currentTimeSlot.wasSmartGuessed else { return }
            
            if currentTimeSlot.category == .unknown || currentTimeSlot.wasSmartGuessed
            {
                self.timeSlotService.update(timeSlot: currentTimeSlot, withCategory: .commute)
            }
        }
        else
        {
            if currentTimeSlot.startTime < previousLocation.timestamp
            {
                let guessedCategory = self.smartGuessService.getCategory(forLocation: previousLocation)
                
                let intervalTimeSlot = TimeSlot(withLocation: previousLocation, smartGuessedCategory: guessedCategory)
                self.timeSlotService.add(timeSlot: intervalTimeSlot)
            }
            
            //We should keep the coordinates at the startDate.
            let category = self.smartGuessService.getCategory(forLocation: location)
            let newTimeSlot = TimeSlot(withLocation: location, smartGuessedCategory: category)
            self.timeSlotService.add(timeSlot: newTimeSlot)
            
            //We only schedule notifications if we couldn't guess any category
            guard category == .unknown else { return }
        }
        
        self.notificationService.unscheduleAllNotifications()
        
        let notificationDate = Date().addingTimeInterval(self.notificationTimeout)
        self.notificationService.scheduleNotification(date: notificationDate,
                                                      title: self.notificationTitle,
                                                      message: self.notificationBody)
    }
    
    func onAppState(_ appState: AppState)
    {
        self.isOnBackground = appState == .inactive
    }
}
