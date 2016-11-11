import Foundation
import UIKit
import UserNotifications

@available(iOS 10.0, *)
class PostiOSTenNotificationService : NotificationService
{
    //MARK: Fields
    private let loggingService : LoggingService
    private let persistencyService: PersistencyService
    
    //MARK: Initializers
    init(loggingService: LoggingService, persistencyService: PersistencyService)
    {
        self.loggingService = loggingService
        self.persistencyService = persistencyService
    }
    
    //MARK: NotificationService implementation
    func requestNotificationPermission(completed: @escaping () -> ())
    {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge],
                                                                completionHandler: { (granted, error) in completed() })
    }
    
    func scheduleNotification(date: Date, title: String, message: String)
    {
        loggingService.log(withLogLevel: .debug, message: "Scheduling message for date: \(date)")
        
        let notification = UILocalNotification()
        notification.fireDate = date
        notification.alertTitle = title
        notification.alertBody = message
        notification.alertAction = "Superday"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.category = Constants.notificationTimeSlotCategorySelectionIdentifier
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let lastThreeTimeSlotsDictionary = persistencyService.getTimeSlots(forDay: Date(), last: 3).map { (timeSlot) -> [String: String] in
            var timeSlotDictionary = [String: String]()
            timeSlotDictionary["color"] = timeSlot.category.colorHex
            if timeSlot.category != .unknown {
                timeSlotDictionary["category"] = timeSlot.category.rawValue.capitalized
            }
            timeSlotDictionary["date"] = formatter.string(from: timeSlot.startTime)
            return timeSlotDictionary
        }
        
        notification.userInfo = ["timeSlots": lastThreeTimeSlotsDictionary]
        
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    func unscheduleAllNotifications()
    {
        guard let notifications = UIApplication.shared.scheduledLocalNotifications, notifications.count > 0 else
        {
            loggingService.log(withLogLevel: .warning, message: "Tried to unschedule notifications, but none are currently scheduled")
            return
        }
        
        notifications.forEach { n in UIApplication.shared.cancelLocalNotification(n)  }
    }
    
    func handleNotificationAction(withIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        if let identifier = identifier, let category = Category(rawValue: identifier) {
            
            let timeSlot = persistencyService.getLastTimeSlot()
            persistencyService.updateTimeSlot(timeSlot, withCategory: category)
            timeSlot.category = category
        }
        completionHandler()
    }
    
    
    // MARK: - User Notification Action
    func setUserNotificationActions() {
        let food = UNNotificationAction(
            identifier: Category.food.rawValue,
            title: Category.food.rawValue.capitalized.translate()
        )
        let friends = UNNotificationAction(
            identifier: Category.friends.rawValue,
            title: Category.friends.rawValue.capitalized.translate()
        )
        let work = UNNotificationAction(
            identifier: Category.work.rawValue,
            title: Category.work.rawValue.capitalized.translate()
        )
        let leisure = UNNotificationAction(
            identifier: Category.leisure.rawValue,
            title: Category.leisure.rawValue.capitalized.translate()
        )
        let category = UNNotificationCategory(
            identifier: Constants.notificationTimeSlotCategorySelectionIdentifier,
            actions: [food, friends, work, leisure],
            intentIdentifiers: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
