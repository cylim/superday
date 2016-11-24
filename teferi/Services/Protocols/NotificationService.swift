import Foundation
import UserNotificationsUI

protocol NotificationService
{
    func requestNotificationPermission(completed: @escaping () -> ())
    
    func scheduleNotification(date: Date, title: String, message: String)
    
    func unscheduleAllNotifications()
    
    func handleNotificationAction(withIdentifier identifier: String?)
}
