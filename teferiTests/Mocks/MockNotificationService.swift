import Foundation
@testable import teferi

class MockNotificationService : NotificationService
{
    var schedulings = 0
    var cancellations = 0
    var scheduledNotifications = 0
    var shouldShowFakeTimeSlot : Bool?
    
    var subscriptions : [(teferi.Category) -> ()] = []
    
    func requestNotificationPermission(completed: @escaping () -> ())
    {
        completed()
    }
    
    func scheduleNotification(date: Date, title: String, message: String, possibleFutureSlotStart: Date?)
    {
        self.shouldShowFakeTimeSlot = possibleFutureSlotStart != nil
        self.schedulings += 1
        self.scheduledNotifications += 1
    }
    
    func unscheduleAllNotifications()
    {
        self.cancellations += 1
        self.scheduledNotifications = 0
    }
    
    func handleNotificationAction(withIdentifier identifier: String?)
    {
        
    }
    
    func subscribeToCategoryAction(_ action : @escaping (teferi.Category) -> ())
    {
        self.subscriptions.append(action)
    }
    
    
    func sendAction(withCategory category : teferi.Category)
    {
        self.subscriptions.forEach { $0(category) }
    }
}
