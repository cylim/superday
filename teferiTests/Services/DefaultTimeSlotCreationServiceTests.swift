import XCTest
import CoreLocation
import Nimble
@testable import teferi

class TrackingServiceTests : XCTestCase
{
    private var location : CLLocation!
    private var loggingService : LoggingService!
    private var settingsService : SettingsService!
    private var trackingService : TrackingService!
    private var timeSlotService : MockTimeSlotService!
    private var notificationService : NotificationService!
    
    override func setUp()
    {
        self.location = CLLocation()
        self.loggingService = MockLoggingService()
        self.settingsService = MockSettingsService()
        self.timeSlotService = MockTimeSlotService()
        self.notificationService = MockNotificationService()
        self.trackingService = DefaultTrackingService(loggingService: self.loggingService,
                                               settingsService: self.settingsService,
                                               timeSlotService: self.timeSlotService,
                                               notificationService: self.notificationService)
    }
    
    func testTheAlgorithmWillNotRunForTheFirstLocationEverReceived()
    {
        self.trackingService.onNewLocation(location)
        
        expect(self.timeSlotService.getLastTimeSlotWasCalled).to(beFalse())
    }
    
    func testTheAlgorithmWillNotRunIfTheNewLocationIsOlderThanTheLastLocationReceived()
    {
        self.settingsService.setLastLocationDate(Date())
        let oldLocation = self.getLocation(withTimestamp: self.settingsService.lastLocationDate!.addingTimeInterval(-90))
        
        self.trackingService.onNewLocation(oldLocation)
        
        expect(self.timeSlotService.getLastTimeSlotWasCalled).to(beFalse())
    }
    
    func testTheAlgorithmDetectsACommuteIfMultipleEntriesHappenInAShortPeriodOfTime()
    {
        let date = getDate(minutesInThePast: 15)
        
        let timeSlot = TimeSlot(withStartDate: date)
        self.timeSlotService.add(timeSlot: timeSlot)
        
        self.settingsService.setLastLocationDate(date)
        
        self.trackingService.onNewLocation(location)
        
        expect(timeSlot.category).to(equal(Category.commute))
    }
    
    func testTheAlgorithmDoesntChangeTheTimeSlotToCommuteIfTheUserHasAlreadySpecifiedTheTimeSlotCategory()
    {
        let date = getDate(minutesInThePast: 15)
        
        let timeSlot = TimeSlot(withStartDate: date)
        timeSlot.category = .work
        self.timeSlotService.add(timeSlot: timeSlot)
        
        self.settingsService.setLastLocationDate(date)
        
        self.trackingService.onNewLocation(location)
        
        expect(timeSlot.category).to(equal(Category.work))
    }
    
    func testTheAlgorithmDetectsNewTimeEntryWhenANewUpdateComesAfterAWhile()
    {
        let date = getDate(minutesInThePast: 30)
        
        let timeSlot = TimeSlot(withStartDate: date)
        self.timeSlotService.add(timeSlot: timeSlot)
        
        self.settingsService.setLastLocationDate(date)
        
        self.trackingService.onNewLocation(location)
        
        let allTimeSlots = self.timeSlotService.getTimeSlots(forDay: date)
        let newlyCreatedTimeSlot = allTimeSlots.last!
        
        expect(allTimeSlots.count).to(equal(2))
        expect(newlyCreatedTimeSlot.startTime).to(equal(self.location.timestamp))
    }
    
    func testTheAlgorithmDoesNotCreateNewTimeSlotsUntilItDetectsTheUserBeingIdleForAWhile()
    {
        let initialDate = self.getDate(minutesInThePast: 130)
        self.timeSlotService.add(timeSlot: TimeSlot(withStartDate: initialDate))
        
        let dates = [ 120, 110, 90, 50, 40, 45, 0 ].map(self.getDate)
            
        dates.map(self.getLocation)
            .forEach(self.trackingService.onNewLocation)
        
        let allTimeSlots = self.timeSlotService.getTimeSlots(forDay: Date())
        let commutesDetected = allTimeSlots.filter { t in t.category == .commute }
        
        expect(allTimeSlots.count).to(equal(5))
        expect(commutesDetected.count).to(equal(2))
        expect(allTimeSlots[3].startTime).to(equal(dates[4]))
    }
    
    func getDate(minutesInThePast: Int) -> Date
    {
        return Date().addingTimeInterval(Double(-minutesInThePast * 60))
    }
    
    func getLocation(withTimestamp date: Date) -> CLLocation
    {
        return CLLocation(coordinate: self.location.coordinate,
                          altitude: self.location.altitude,
                          horizontalAccuracy: self.location.horizontalAccuracy,
                          verticalAccuracy: self.location.verticalAccuracy,
                          timestamp: date)
    }
}
