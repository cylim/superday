import Foundation
import UserNotificationsUI

protocol NotificationService
{
    func requestNotificationPermission(completed: @escaping () -> ())
    
    func scheduleNotification(date: Date, title: String, message: String, possibleFutureSlotStart: Date?)
    
    func unscheduleAllNotifications()
    
    func handleNotificationAction(withIdentifier identifier: String?)
    
    func subscribeToCategoryAction(_ action : @escaping (Category) -> ())
}
