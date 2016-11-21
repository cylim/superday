import Foundation
import UIKit

class DefaultNotificationService : NotificationService
{
    //MARK: Fields
    private let loggingService : LoggingService
    
    //MARK: Initializers
    init(loggingService: LoggingService)
    {
        self.loggingService = loggingService
    }
    
    //MARK: NotificationService implementation
    func scheduleNotification(date: Date, message: String)
    {
        self.loggingService.log(withLogLevel: .debug, message: "Scheduling message for date: \(date)")
        
        let notification = UILocalNotification()
        notification.fireDate = date
        notification.alertBody = message
        notification.alertAction = "Superday"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    func unscheduleAllNotifications()
    {
        guard let notifications = UIApplication.shared.scheduledLocalNotifications, notifications.count > 0 else
        {
            self.loggingService.log(withLogLevel: .warning, message: "Tried to unschedule notifications, but none are currently scheduled")
            return
        }
        
        notifications.forEach { n in UIApplication.shared.cancelLocalNotification(n)  }
    }
}
