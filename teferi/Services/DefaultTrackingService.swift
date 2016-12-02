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
            if !currentTimeSlot.categoryWasSetByUser
            {
                self.timeSlotService.update(timeSlot: currentTimeSlot, withCategory: .commute, setByUser: false)
            }
        }
        else
        {
            if currentTimeSlot.startTime < previousLocation.timestamp
            {
                self.persistTimeSlot(withLocation: previousLocation)
            }
            
            //We should keep the coordinates at the startDate.
            let guessedCategory = self.persistTimeSlot(withLocation: location)
            
            //We only schedule notifications if we couldn't guess any category
            guard guessedCategory == .unknown else { return }
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
    
    @discardableResult private func persistTimeSlot(withLocation location: CLLocation) -> Category
    {
        let smartGuess = self.smartGuessService.get(forLocation: location)
        
        let timeSlot = smartGuess === SmartGuess.empty ?
            TimeSlot(withStartTime: location.timestamp, category: .unknown) :
            TimeSlot(withStartTime: location.timestamp, smartGuess: smartGuess)
        
        self.timeSlotService.add(timeSlot: timeSlot)
        
        return smartGuess.category
    }
}
