import Foundation

protocol NotificationService
{
    func scheduleNotification(date: Date, message: String)
    
    func unscheduleAllNotifications()
}
