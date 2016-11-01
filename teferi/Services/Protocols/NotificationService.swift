import Foundation

protocol NotificationService
{
    func requestNotificationPermission(completed: @escaping () -> ())
    
    func scheduleNotification(date: Date, message: String)
    
    func unscheduleAllNotifications()
}
