import Foundation
import XCTest
import RxSwift
import Nimble
@testable import teferi

class TimelineViewModelTests : XCTestCase
{
    private var disposable : Disposable? = nil
    private var viewModel : TimelineViewModel!
    private var mockMetricsService : MockMetricsService!
    private var mockAppStateService : MockAppStateService!
    private var mockTimeSlotService : MockTimeSlotService!

    override func setUp()
    {
        self.mockMetricsService = MockMetricsService()
        self.mockAppStateService = MockAppStateService()
        self.mockTimeSlotService = MockTimeSlotService()
        
        self.viewModel = TimelineViewModel(date: Date(),
                                           metricsService: self.mockMetricsService,
                                           appStateService: self.mockAppStateService,
                                           timeSlotService: self.mockTimeSlotService)
    }
    
    override func tearDown()
    {
        self.disposable?.dispose()
    }
    
    func testOnlyViewModelsForTheCurrentDaySubscribeForTimeSlotUpdates()
    {
        expect(self.mockTimeSlotService.didSubscribe).to(beTrue())
    }
    
    func testIfThereAreNoTimeSlotsForTheCurrentDayTheViewModelCreatesOne()
    {
        expect(self.viewModel.timeSlots.count).to(equal(1))
    }
    
    func testViewModelsForTheOlderDaysDoNotSubscribeForTimeSlotUpdates()
    {
        let newMockTimeSlotService = MockTimeSlotService()
        _ = TimelineViewModel(date: Date().yesterday,
                              metricsService: self.mockMetricsService,
                              appStateService: self.mockAppStateService,
                              timeSlotService: newMockTimeSlotService)
        
        expect(newMockTimeSlotService.didSubscribe).to(beFalse())
    }
    
    func testTheNewlyAddedSlotHasNoEndTime()
    {
        let timeSlot = self.createTimeSlot()
        self.mockTimeSlotService.add(timeSlot: timeSlot)
        let lastSlot = viewModel.timeSlots.last!
        
        expect(lastSlot.endTime).to(beNil())
    }
    
    func testTheAddNewSlotsMethodEndsThePreviousTimeSlot()
    {
        let timeSlot = self.createTimeSlot()
        self.mockTimeSlotService.add(timeSlot: timeSlot)
        let firstSlot = viewModel.timeSlots.first!
        
        let otherTimeSlot = self.createTimeSlot()
        self.mockTimeSlotService.add(timeSlot: otherTimeSlot)
        
        expect(firstSlot.endTime).toNot(beNil())
    }
    
    private func createTimeSlot() -> TimeSlot
    {
        return TimeSlot(withStartTime: Date(), category: .work, categoryWasSetByUser: false)
    }
}
