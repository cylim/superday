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
    private var settingsService : SettingsService
    private let timeSlotService : TimeSlotService
    private let notificationService : NotificationService
    
    private var isOnBackground = false
    
    //MARK: Init
    init(loggingService: LoggingService,
         settingsService: SettingsService,
         timeSlotService: TimeSlotService,
         notificationService: NotificationService)
    {
        self.loggingService = loggingService
        self.settingsService = settingsService
        self.timeSlotService = timeSlotService
        self.notificationService = notificationService
        
        notificationService.subscribeToCategoryAction(self.onNotificationAction)
    }
    
    //MARK:  TrackingService implementation
    func onLocation(_ location: CLLocation)
    {
        guard self.isOnBackground else { return }
        
        let currentLocationTime = location.timestamp
        
        guard let previousLocationTime = self.settingsService.lastLocationDate else
        {
            self.settingsService.setLastLocationDate(currentLocationTime)
            return
        }
        
        guard currentLocationTime > previousLocationTime else { return }
        
        self.settingsService.setLastLocationDate(currentLocationTime)
        
        let currentTimeSlot = self.timeSlotService.getLast()
        
        if self.isCommute(now: currentLocationTime, then: previousLocationTime)
        {
            if currentTimeSlot.category == .unknown
            {
                self.timeSlotService.update(timeSlot: currentTimeSlot, withCategory: .commute)
            }
        }
        else
        {
            if currentTimeSlot.startTime < previousLocationTime
            {
                self.startTimeSlot(withStartTime: previousLocationTime)
            }
            self.startTimeSlot(withStartTime: currentLocationTime)
        }
        
        self.notificationService.unscheduleAllNotifications()
        
        let notificationDate = Date().addingTimeInterval(self.notificationTimeout)
        self.notificationService.scheduleNotification(date: notificationDate,
                                                      title: self.notificationTitle,
                                                      message: self.notificationBody)
    }
    
    private func onNotificationAction(withCategory category : Category)
    {
        self.tryStoppingCommuteRetroactively(at: Date())
        
        let currentTimeSlot = self.timeSlotService.getLast()
        self.timeSlotService.update(timeSlot: currentTimeSlot, withCategory: category)
    }
    
    private func onAppActivates(at time : Date)
    {
        self.tryStoppingCommuteRetroactively(at: time)
    }
    
    private func tryStoppingCommuteRetroactively(at time : Date)
    {
        guard let lastLocationTime = self.settingsService.lastLocationDate else { return }
        
        let currentTimeSlot = self.timeSlotService.getLast()
        
        guard
            currentTimeSlot.category == .commute,
            currentTimeSlot.startTime <= lastLocationTime,
            !self.isCommute(now: time, then: lastLocationTime)
        else { return }
        
        self.startTimeSlot(withStartTime: lastLocationTime)
    }
    
    private func isCommute(now : Date, then : Date) -> Bool
    {
        return now.timeIntervalSince(then) / 60 < 25.0
    }
    
    private func startTimeSlot(withStartTime startTime : Date)
    {
        let newTimeSlot = TimeSlot(withStartDate: startTime)
        self.timeSlotService.add(timeSlot: newTimeSlot)
    }
    
    func onAppState(_ appState: AppState)
    {
        if appState == .active
        {
            self.onAppActivates(at: Date())
        }
        
        self.isOnBackground = appState == .inactive
    }
}
