import Foundation
import XCTest
import RxSwift
import Nimble
@testable import teferi

class TimelineViewModelTests : XCTestCase
{
    private var disposable : Disposable? = nil
    private var viewModel : TimelineViewModel!
    
    private var timeService : TimeService!
    private var metricsService : MockMetricsService!
    private var appStateService : MockAppStateService!
    private var timeSlotService : MockTimeSlotService!
    private var editStateService : MockEditStateService!
    
    override func setUp()
    {
        self.timeService = MockTimeService()
        self.metricsService = MockMetricsService()
        self.appStateService = MockAppStateService()
        self.timeSlotService = MockTimeSlotService()
        self.editStateService = MockEditStateService()
        
        self.viewModel = TimelineViewModel(date: Date(),
                                           timeService: self.timeService,
                                           metricsService: self.metricsService,
                                           appStateService: self.appStateService,
                                           timeSlotService: self.timeSlotService,
                                           editStateService: self.editStateService)
    }
    
    override func tearDown()
    {
        self.disposable?.dispose()
    }
    
    func testOnlyViewModelsForTheCurrentDaySubscribeForTimeSlotUpdates()
    {
        expect(self.timeSlotService.didSubscribe).to(beTrue())
    }
    
    func testIfThereAreNoTimeSlotsForTheCurrentDayTheViewModelCreatesOne()
    {
        expect(self.viewModel.timeSlots.count).to(equal(1))
    }
    
    func testViewModelsForTheOlderDaysDoNotSubscribeForTimeSlotUpdates()
    {
        let newMockTimeSlotService = MockTimeSlotService()
        _ = TimelineViewModel(date: Date().yesterday,
                              timeService: self.timeService,
                              metricsService: self.metricsService,
                              appStateService: self.appStateService,
                              timeSlotService: newMockTimeSlotService,
                              editStateService: self.editStateService)
        
        expect(newMockTimeSlotService.didSubscribe).to(beFalse())
    }
    
    func testTheNewlyAddedSlotHasNoEndTime()
    {
        let timeSlot = self.createTimeSlot()
        self.timeSlotService.add(timeSlot: timeSlot)
        let lastSlot = viewModel.timeSlots.last!
        
        expect(lastSlot.endTime).to(beNil())
    }
    
    func testTheAddNewSlotsMethodEndsThePreviousTimeSlot()
    {
        let timeSlot = self.createTimeSlot()
        self.timeSlotService.add(timeSlot: timeSlot)
        let firstSlot = viewModel.timeSlots.first!
        
        let otherTimeSlot = self.createTimeSlot()
        self.timeSlotService.add(timeSlot: otherTimeSlot)
        
        expect(firstSlot.endTime).toNot(beNil())
    }
    
    private func createTimeSlot() -> TimeSlot
    {
        return TimeSlot(withStartTime: Date(), category: .work, categoryWasSetByUser: false)
    }
}
