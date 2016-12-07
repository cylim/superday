import Foundation
@testable import teferi

class MockNotificationService : NotificationService
{
    var scheduledNotifications = 0
    
    func requestNotificationPermission(completed: @escaping () -> ())
    {
        completed()
    }
    
    func scheduleNotification(date: Date, title: String, message: String)
    {
        scheduledNotifications += 1
    }
    
    func unscheduleAllNotifications()
    {
        scheduledNotifications = 0
    }
    
    func handleNotificationAction(withIdentifier identifier: String?)
    {
        
    }
    
    func subscribeToCategoryAction(_ action : @escaping (teferi.Category) -> ())
    {
        
    }
}
