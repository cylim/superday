import Foundation
@testable import teferi

class MockNotificationService : NotificationService
{
    var scheduledNotifications = 0
    
    func requestNotificationPermission(completed: @escaping () -> ())
    {
        completed()
    }
    
    func scheduleNotification(date: Date, message: String)
    {
        scheduledNotifications += 1
    }
    
    func unscheduleAllNotifications()
    {
        scheduledNotifications = 0
    }
}
