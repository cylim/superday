import UIKit
import XCTest
import CoreGraphics
import Nimble
@testable import teferi

class DefaultTimeSlotCreationServiceTests : XCTestCase
{
    private var loggingService: LoggingService!
    private var settingsService: SettingsService!
    private var persistencyService: PersistencyService!
    private var notificationService: NotificationService!
    private var timeSlotCreationService : TimeSlotCreationService!
    
    override func setUp()
    {
        self.loggingService = MockLoggingService()
        self.settingsService = MockSettingsService()
        self.persistencyService = MockPersistencyService()
        self.notificationService = MockNotificationService()
        self.timeSlotCreationService = DefaultTimeSlotCreationService(settingsService: self.settingsService,
                                                                      persistencyService: self.persistencyService,
                                                                      loggingService: self.loggingService,
                                                                      notificationService: self.notificationService)
    }
}
