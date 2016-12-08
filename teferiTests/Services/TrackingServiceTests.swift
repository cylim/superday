import XCTest
import CoreLocation
import Nimble
@testable import teferi

class TrackingServiceTests : XCTestCase
{
    private var midnight : Date!
    private var noon : Date!
    private var locationDummy : CLLocation!
    private var loggingService : LoggingService!
    private var settingsService : SettingsService!
    private var trackingService : TrackingService!
    private var timeSlotService : MockTimeSlotService!
    private var smartGuessService : SmartGuessService!
    private var notificationService : MockNotificationService!
    
    override func setUp()
    {
        self.midnight = Date().ignoreTimeComponents()
        self.noon = self.midnight.addingTimeInterval(12 * 60 * 60)
        self.locationDummy = CLLocation()
        self.loggingService = MockLoggingService()
        self.settingsService = MockSettingsService()
        self.timeSlotService = MockTimeSlotService()
        self.smartGuessService = MockSmartGuessService()
        self.notificationService = MockNotificationService()
        
        self.trackingService = DefaultTrackingService(loggingService: self.loggingService,
                                                      settingsService: self.settingsService,
                                                      timeSlotService: self.timeSlotService,
                                                      smartGuessService: self.smartGuessService,
                                                      notificationService: self.notificationService)
        
        self.trackingService.onAppState(.inactive)
    }
    
    func testTheAlgorithmWillIgnoreLocationsWhileOnForeground()
    {
        self.trackingService.onAppState(.active)
        
        [ 40, 30, 20, 10]
            .map(self.getDate)
            .map(self.getLocation)
            .forEach(self.trackingService.onLocation)
        
        expect(self.timeSlotService.getLastTimeSlotWasCalled).to(beFalse())
    }
    
    func testTheAlgorithmWillNotRunForTheFirstLocationEverReceived()
    {
        let location = self.getLocation(withTimestamp: self.noon)
        self.trackingService.onLocation(location)
        
        expect(self.timeSlotService.getLastTimeSlotWasCalled).to(beFalse())
    }
    
    func testTheAlgorithmWillNotRunIfTheNewLocationIsOlderThanTheLastLocationReceived()
    {
        self.settingsService.setLastLocation(self.getLocation(withTimestamp: self.noon))
        let oldLocation = self.getLocation(withTimestamp: self.getDate(minutesBeforeNoon: 1))
        
        self.trackingService.onLocation(oldLocation)
        
        expect(self.timeSlotService.getLastTimeSlotWasCalled).to(beFalse())
    }
    
    func testTheAlgorithmDetectsACommuteIfMultipleEntriesHappenInAShortPeriodOfTime()
    {
        self.setupFirstTimeSlotAndLastLocation(minutesBeforeNoon: 15)
        
        let location = self.getLocation(withTimestamp: self.noon)
        self.trackingService.onLocation(location)
        
        let timeSlot = self.timeSlotService.timeSlots[0]
        expect(timeSlot.category).to(equal(Category.commute))
    }
    
    func testTheAlgorithmDoesNotChangeTheTimeSlotToCommuteIfTheCurrentTimeSlotCategoryWasSetByTheUser()
    {
        let date = self.getDate(minutesBeforeNoon: 15)
        
        let timeSlot = TimeSlot(withStartTime: date, categoryWasSetByUser: false)
        timeSlot.category = .work
        timeSlot.categoryWasSetByUser = true
        self.timeSlotService.add(timeSlot: timeSlot)
        
        self.settingsService.setLastLocation(self.getLocation(withTimestamp: date))
        
        let location = self.getLocation(withTimestamp: self.noon)
        self.trackingService.onLocation(location)
        
        expect(timeSlot.category).to(equal(Category.work))
    }
    
    func testTheAlgorithmDoesChangeTheTimeSlotToCommuteIfTheCurrentTimeSlotCategoryWasNotSetByTheUser()
    {
        let date = self.getDate(minutesBeforeNoon: 15)
        
        let timeSlot = TimeSlot(withStartTime: date, categoryWasSetByUser: false)
        timeSlot.category = .work
        self.timeSlotService.add(timeSlot: timeSlot)
        
        self.settingsService.setLastLocation(self.getLocation(withTimestamp: date))
        
        let location = self.getLocation(withTimestamp: self.noon)
        self.trackingService.onLocation(location)
        
        expect(timeSlot.category).to(equal(Category.commute))
    }
    
    func testTheAlgorithmCreatesNewTimeSlotWhenANewUpdateComesAfterAWhile()
    {
        
        self.setupFirstTimeSlotAndLastLocation(minutesBeforeNoon: 30)
        
        let location = self.getLocation(withTimestamp: self.noon)
        self.trackingService.onLocation(location)
        
        let allTimeSlots = self.timeSlotService.getTimeSlots(forDay: self.getDate(minutesBeforeNoon: 30))
        let newlyCreatedTimeSlot = allTimeSlots.last!
        
        expect(allTimeSlots.count).to(equal(2))
        expect(newlyCreatedTimeSlot.startTime).to(equal(location.timestamp))
    }
    
    func testTheAlgorithmDoesNotCreateNewTimeSlotsUntilItDetectsTheUserBeingIdleForAWhile()
    {
        let initialDate = self.getDate(minutesBeforeNoon: 130)
        self.timeSlotService.add(timeSlot: TimeSlot(withStartTime: initialDate, categoryWasSetByUser: false))
        
        let dates = [ 120, 110, 90, 50, 40, 45, 0 ].map(self.getDate)
            
        dates.map(self.getLocation)
            .forEach(self.trackingService.onLocation)
        
        let allTimeSlots = self.timeSlotService.getTimeSlots(forDay: self.noon)
        let commutesDetected = allTimeSlots.filter { t in t.category == .commute }
        
        expect(allTimeSlots.count).to(equal(5))
        expect(commutesDetected.count).to(equal(2))
        expect(allTimeSlots[3].startTime).to(equal(dates[4]))
    }
    
    func testTheAlgorithmReschedulesNotificationsOnCommute()
    {
        self.setupFirstTimeSlotAndLastLocation(minutesBeforeNoon: 15)
        
        let location = self.getLocation(withTimestamp: self.noon)
        self.trackingService.onLocation(location)
        
        expect(self.notificationService.cancellations).to(equal(1))
        expect(self.notificationService.schedulings).to(equal(1))
        expect(self.notificationService.scheduledNotifications).to(equal(1))
    }
    
    func testTheAlgorithmRechedulesNotificationsOnNonCommute()
    {
        self.setupFirstTimeSlotAndLastLocation(minutesBeforeNoon: 30)
        
        let location = self.getLocation(withTimestamp: self.noon)
        self.trackingService.onLocation(location)
        
        expect(self.notificationService.cancellations).to(equal(1))
        expect(self.notificationService.schedulings).to(equal(1))
        expect(self.notificationService.scheduledNotifications).to(equal(1))
    }
    
    func setupFirstTimeSlotAndLastLocation(minutesBeforeNoon : Int)
    {
        let date = self.getDate(minutesBeforeNoon: minutesBeforeNoon)
        
        let timeSlot = TimeSlot(withStartTime: date, categoryWasSetByUser: false)
        self.timeSlotService.add(timeSlot: timeSlot)
        
        self.settingsService.setLastLocation(self.getLocation(withTimestamp: date))
    }
    
    func getDate(minutesBeforeNoon: Int) -> Date
    {
        return self.noon
            .addingTimeInterval(Double(-minutesBeforeNoon * 60))
    }
    
    func getLocation(withTimestamp date: Date) -> CLLocation
    {
        let location = self.locationDummy!
        return CLLocation(coordinate: location.coordinate,
                          altitude: location.altitude,
                          horizontalAccuracy: location.horizontalAccuracy,
                          verticalAccuracy: location.verticalAccuracy,
                          timestamp: date)
    }
}
