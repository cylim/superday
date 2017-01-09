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
    
    func testConsecutiveTimeSlotsShouldNotDisplayTheCategoryText()
    {
        self.timeSlotService.add(timeSlot: self.createTimeSlot())
        self.timeSlotService.add(timeSlot: self.createTimeSlot())
        
        expect(self.viewModel.timeSlots.last!.shouldDisplayCategoryName).to(beFalse())
    }
    
    func testUpdatingTheNthTimeSlotShouldRecalculateWhetherTheNPlus1thShouldDisplayTheCategoryTextOrNot()
    {
        self.timeSlotService.add(timeSlot: self.createTimeSlot())
        self.timeSlotService.add(timeSlot: self.createTimeSlot())
        self.timeSlotService.add(timeSlot: self.createTimeSlot())
        self.timeSlotService.add(timeSlot: self.createTimeSlot())
        
        self.timeSlotService.update(timeSlot: self.viewModel.timeSlots[2], withCategory: .leisure, setByUser: true)
        
        [ true, true, true, true, false ]
            .enumerated()
            .forEach { i, result in expect(self.viewModel.timeSlots[i].shouldDisplayCategoryName).to(equal(result)) }
    }
    
    func testTheViewModelInitializesVerifyingTheShouldDisplayCategoryLogic()
    {
        self.timeSlotService = MockTimeSlotService()
        self.timeSlotService.add(timeSlot: self.createTimeSlot())
        
        let timeSlot = self.createTimeSlot()
        self.timeSlotService.add(timeSlot: timeSlot)
        self.timeSlotService.update(timeSlot: timeSlot, withCategory: .leisure, setByUser: true)
        
        self.timeSlotService.add(timeSlot: self.createTimeSlot())
        self.timeSlotService.add(timeSlot: self.createTimeSlot())
     
        self.viewModel = TimelineViewModel(date: Date(),
                                           timeService: self.timeService,
                                           metricsService: self.metricsService,
                                           appStateService: self.appStateService,
                                           timeSlotService: self.timeSlotService,
                                           editStateService: self.editStateService)
        
        [ true, true, true, false ]
            .enumerated()
            .forEach { i, result in expect(self.viewModel.timeSlots[i].shouldDisplayCategoryName).to(equal(result)) }
    }
    
    private func createTimeSlot() -> TimeSlot
    {
        return TimeSlot(withStartTime: Date(), category: .work, categoryWasSetByUser: false)
    }
}
