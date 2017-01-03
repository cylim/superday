import XCTest
import CoreLocation
import Nimble
@testable import teferi

class TrackingServiceTests : XCTestCase
{
    private let baseCoordinates = CLLocationCoordinate2D(latitude: 37.628060, longitude: -116.848463)
    private let metersToLatitudeFactor = 1.0 / 111_000
    private let defaultMovementSpeed = 100.0 // (meters/minute)
    
    private var midnight : Date!
    private var noon : Date!
    
    private var timeService : TimeService!
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
        
        self.timeService = MockTimeService()
        self.loggingService = MockLoggingService()
        self.settingsService = MockSettingsService()
        self.timeSlotService = MockTimeSlotService()
        self.smartGuessService = MockSmartGuessService()
        self.notificationService = MockNotificationService()
        
        self.trackingService = DefaultTrackingService(timeService: self.timeService,
                                                      loggingService: self.loggingService,
                                                      settingsService: self.settingsService,
                                                      timeSlotService: self.timeSlotService,
                                                      smartGuessService: self.smartGuessService,
                                                      notificationService: self.notificationService)
        
        
        self.trackingService.onAppState(.inactive)
    }
    
    func testTheTestHelpersCalculateLocationDifferencesCorrectly()
    {
        let close = 100.0
        let far = 123_456.0
        let expectedAccuracy = 1.0 / 1000.0
        
        let baseLocation = self.getLocation(withTimestamp: self.noon, metersFromOrigin: 0)
        let closeLocation = self.getLocation(withTimestamp: self.noon, metersFromOrigin: close)
        let farLocation = self.getLocation(withTimestamp: self.noon, metersFromOrigin: far)
        let oppositeLocation = self.getLocation(withTimestamp: self.noon, metersFromOrigin: -far)
        
        expect(closeLocation.distance(from: baseLocation)).to(beCloseTo(close, within: close * expectedAccuracy))
        expect(farLocation.distance(from: baseLocation)).to(beCloseTo(far, within: far * expectedAccuracy))
        expect(oppositeLocation.distance(from: baseLocation)).to(beCloseTo(far, within: far * expectedAccuracy))
    }
    
    func testTheTestHelpersCreateLocationsBasedOnDefaultSpeed()
    {
        let minutes = 20
        let meters = Double(minutes) * self.defaultMovementSpeed
        let accuracy = 1.0 / 1000.0
        
        let baseLocation = self.getLocation(withTimestamp: self.noon)
        let futureLocation = self.getLocation(withTimestamp: self.getDate(minutesPastNoon: minutes))
        
        expect(futureLocation.distance(from: baseLocation)).to(beCloseTo(meters, within: meters * accuracy))
    }
    
    func testTheAlgorithmWillIgnoreLocationsWhileOnForeground()
    {
        self.trackingService.onAppState(.active)
        
        [10, 20, 30, 40]
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
        let oldLocation = self.getLocation(withTimestamp: self.getDate(minutesPastNoon: -1))
        
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
        let timeSlot = self.setupFirstTimeSlotAndLastLocation(minutesBeforeNoon: 0, slotCategory: .work, wasSetByUser: true)
        
        let location = self.getLocation(withTimestamp: self.getDate(minutesPastNoon: 15))
        self.trackingService.onLocation(location)
        
        expect(timeSlot.category).to(equal(Category.work))
    }
    
    func testTheAlgorithmDoesChangeTheTimeSlotToCommuteIfTheCurrentTimeSlotCategoryWasNotSetByTheUser()
    {
        let timeSlot = self.setupFirstTimeSlotAndLastLocation(minutesBeforeNoon: 0, slotCategory: .work, wasSetByUser: false)
        
        let location = self.getLocation(withTimestamp: self.getDate(minutesPastNoon: 15))
        self.trackingService.onLocation(location)
        
        expect(timeSlot.category).to(equal(Category.commute))
    }
    
    func testTheAlgorithmCreatesNewTimeSlotWhenANewUpdateComesAfterAWhile()
    {
        self.setupFirstTimeSlotAndLastLocation(minutesBeforeNoon: 30)
        
        let location = self.getLocation(withTimestamp: self.noon)
        self.trackingService.onLocation(location)
        
        let allTimeSlots = self.timeSlotService.getTimeSlots(forDay: self.noon)
        let newlyCreatedTimeSlot = allTimeSlots.last!
        
        expect(allTimeSlots.count).to(equal(2))
        expect(newlyCreatedTimeSlot.startTime).to(equal(location.timestamp))
    }
    
    func testTheAlgorithmDoesNotCreateNewTimeSlotsUntilItDetectsTheUserBeingIdleForAWhile()
    {
        self.setupFirstTimeSlotAndLastLocation(minutesBeforeNoon: 0)
        
        let dates = [45, 40, 50, 90, 110, 120].map(self.getDate)
            
        dates.map(self.getLocation)
            .forEach(self.trackingService.onLocation)
        
        let allTimeSlots = self.timeSlotService.getTimeSlots(forDay: self.noon)
        let commutesDetected = allTimeSlots.filter { t in t.category == .commute }
        
        expect(allTimeSlots.count).to(equal(4))
        expect(commutesDetected.count).to(equal(2))
        expect(allTimeSlots[1].startTime).to(equal(dates[0]))
        expect(allTimeSlots[2].startTime).to(equal(dates[2]))
        expect(allTimeSlots[3].startTime).to(equal(dates[3]))
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
    
    func testTheAlgorithmDoesNotCreateTimeSlotsFromLocationUpdatesInSimilarLocation()
    {
        self.setupFirstTimeSlotAndLastLocation(minutesBeforeNoon: 0)
        
        let location = self.getLocation(withTimestamp: self.getDate(minutesPastNoon: 30), metersFromOrigin: 20)
        self.trackingService.onLocation(location)
        
        expect(self.timeSlotService.timeSlots.count).to(equal(1))
    }
    
    func testTheAlgorithmDoesNotDetectCommuteFromLocationUpdatesInSimilarLocation()
    {
        self.setupFirstTimeSlotAndLastLocation(minutesBeforeNoon: 0)
        
        let location = self.getLocation(withTimestamp: self.getDate(minutesPastNoon: 15), metersFromOrigin: 20)
        self.trackingService.onLocation(location)
        
        expect(self.timeSlotService.timeSlots.count).to(equal(1))
        expect(self.timeSlotService.timeSlots[0].category).to(equal(Category.unknown))
    }
    
    func testTheAlgorithmDoesNotTouchNotificationsFromLocationUpdatesInSimilarLocation()
    {
        self.setupFirstTimeSlotAndLastLocation(minutesBeforeNoon: 0)
        
        let location = self.getLocation(withTimestamp: self.getDate(minutesPastNoon: 30), metersFromOrigin: 20)
        self.trackingService.onLocation(location)
        
        expect(self.notificationService.cancellations).to(equal(0))
        expect(self.notificationService.schedulings).to(equal(0))
    }
    
    func testTheAlgorithmDoesNotTouchLastKnownLocationFromLocationUpdatesInSimilarLocation()
    {
        self.setupFirstTimeSlotAndLastLocation(minutesBeforeNoon: 0)
        
        let initialLastLocation = self.settingsService.lastLocation!
        
        let location = self.getLocation(withTimestamp: self.getDate(minutesPastNoon: 30), metersFromOrigin: 20)
        self.trackingService.onLocation(location)
        
        expect(self.settingsService.lastLocation).to(equal(initialLastLocation))
    }
    
    // Helper methods
    
    @discardableResult func setupFirstTimeSlotAndLastLocation(minutesBeforeNoon : Int) -> TimeSlot
    {
        return self.setupFirstTimeSlotAndLastLocation(
            minutesBeforeNoon: minutesBeforeNoon, slotCategory: .unknown, wasSetByUser: false)
    }
    
    @discardableResult func setupFirstTimeSlotAndLastLocation(
        minutesBeforeNoon : Int, slotCategory: teferi.Category, wasSetByUser: Bool) -> TimeSlot
    {
        let date = self.getDate(minutesPastNoon: -minutesBeforeNoon)
        
        let timeSlot = TimeSlot(withStartTime: date, categoryWasSetByUser: wasSetByUser)
        timeSlot.category = slotCategory
        self.timeSlotService.add(timeSlot: timeSlot)
        
        self.settingsService.setLastLocation(self.getLocation(withTimestamp: date))
        
        return timeSlot
    }
    
    func getDate(minutesPastNoon minutes: Int) -> Date
    {
        return self.noon
            .addingTimeInterval(Double(minutes * 60))
    }
    
    func getLocation(withTimestamp date: Date) -> CLLocation
    {
        let metersPerSecond = self.defaultMovementSpeed / 60.0
        let secondsSinceNoon = date.timeIntervalSince(self.noon)
        let metersOffset = secondsSinceNoon * metersPerSecond
        
        return self.getLocation(withTimestamp: date, metersFromOrigin: metersOffset)
    }
    
    func getLocation(withTimestamp date: Date, metersFromOrigin distance: Double) -> CLLocation
    {
        let latitudeOffset = distance * self.metersToLatitudeFactor
        let coordinates = CLLocationCoordinate2D(latitude: self.baseCoordinates.latitude + latitudeOffset,
                                                 longitude: self.baseCoordinates.longitude)
        return CLLocation(coordinate: coordinates,
                          altitude: 0,
                          horizontalAccuracy: 0,
                          verticalAccuracy: 0,
                          timestamp: date)
    }
}
