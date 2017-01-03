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
    
    private let timeService : TimeService
    private let loggingService : LoggingService
    private let settingsService : SettingsService
    private let timeSlotService : TimeSlotService
    private let smartGuessService : SmartGuessService
    private let notificationService : NotificationService
    
    private var isOnBackground = false
    
    //MARK: Init
    init(timeService: TimeService,
         loggingService: LoggingService,
         settingsService: SettingsService,
         timeSlotService: TimeSlotService,
         smartGuessService: SmartGuessService,
         notificationService: NotificationService)
    {
        self.timeService = timeService
        self.loggingService = loggingService
        self.settingsService = settingsService
        self.timeSlotService = timeSlotService
        self.smartGuessService = smartGuessService
        self.notificationService = notificationService
        
        notificationService.subscribeToCategoryAction(self.onNotificationAction)
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
        
        guard location.distance(from: previousLocation) > 50 else { return }
        
        self.settingsService.setLastLocation(location)
        
        let currentTimeSlot = self.timeSlotService.getLast()
        
        let scheduleNotification : Bool
        
        if self.isCommute(now: location.timestamp, then: previousLocation.timestamp)
        {
            //If it was smart guessed and we detect movement, we got it wrong and override it with a commute
            if !currentTimeSlot.categoryWasSetByUser
            {
                self.timeSlotService.update(timeSlot: currentTimeSlot, withCategory: .commute, setByUser: false)
            }
            scheduleNotification = true
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
            scheduleNotification = guessedCategory == .unknown
        }
        
        self.cancelNotification(andScheduleNew: scheduleNotification)
    }
    
    private func cancelNotification(andScheduleNew scheduleNew : Bool)
    {
        self.notificationService.unscheduleAllNotifications()
        
        guard scheduleNew else { return }
        
        let notificationDate = self.timeService.now.addingTimeInterval(self.notificationTimeout)
        self.notificationService.scheduleNotification(date: notificationDate,
                                                      title: self.notificationTitle,
                                                      message: self.notificationBody)
    }
    
    private func onNotificationAction(withCategory category : Category)
    {
        self.tryStoppingCommuteRetroactively(at: self.timeService.now)
        
        let currentTimeSlot = self.timeSlotService.getLast()
        self.timeSlotService.update(timeSlot: currentTimeSlot, withCategory: category, setByUser: true)
    }
    
    private func onAppActivates(at time : Date)
    {
        self.tryStoppingCommuteRetroactively(at: time)
    }
    
    private func tryStoppingCommuteRetroactively(at time : Date)
    {
        guard let lastLocation = self.settingsService.lastLocation else { return }
        
        let currentTimeSlot = self.timeSlotService.getLast()
        
        guard
            currentTimeSlot.category == .commute,
            currentTimeSlot.startTime <= lastLocation.timestamp,
            !self.isCommute(now: time, then: lastLocation.timestamp)
        else { return }
        
        self.persistTimeSlot(withLocation: lastLocation)
    }
    
    private func isCommute(now : Date, then : Date) -> Bool
    {
        return now.timeIntervalSince(then) / 60 < 25.0
    }
    
    func onAppState(_ appState: AppState)
    {
        if appState == .active
        {
            self.onAppActivates(at: self.timeService.now)
        }
        
        self.isOnBackground = appState == .inactive
    }
    
    @discardableResult private func persistTimeSlot(withLocation location: CLLocation) -> Category
    {
        let smartGuess = self.smartGuessService.get(forLocation: location)
        
        let timeSlot = smartGuess == nil ?
            TimeSlot(withStartTime: location.timestamp, category: .unknown, location: location, categoryWasSetByUser: false) :
            TimeSlot(withStartTime: location.timestamp, smartGuess: smartGuess!, location: location)
        
        self.timeSlotService.add(timeSlot: timeSlot)
        
        return smartGuess?.category ?? .unknown
    }
}
