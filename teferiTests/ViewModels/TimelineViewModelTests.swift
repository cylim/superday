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
    private var mockPersistencyService : MockPersistencyService!

    override func setUp()
    {
        self.mockMetricsService = MockMetricsService()
        self.mockPersistencyService = MockPersistencyService()
        self.viewModel = TimelineViewModel(date: Date(),
                                      persistencyService: self.mockPersistencyService,
                                      metricsService: self.mockMetricsService)
    }
    
    override func tearDown()
    {
        self.disposable?.dispose()
    }
    
    func testOnlyViewModelsForTheCurrentDaySubscribeForTimeSlotUpdates()
    {
        expect(self.mockPersistencyService.didSubscribe).to(beTrue())
    }
    
    func testViewModelsForTheOlderDaysDoNotSubscribeForTimeSlotUpdates()
    {
        let newMockPersistencyService = MockPersistencyService()
        _ = TimelineViewModel(date: Date().yesterday,
                              persistencyService: newMockPersistencyService,
                              metricsService: self.mockMetricsService)
        
        expect(newMockPersistencyService.didSubscribe).to(beFalse())
    }
    
    func testTheUpdateMethodCallsTheMetricsService()
    {
        let timeSlot = TimeSlot(category: .work)
        self.mockPersistencyService.addNewTimeSlot(timeSlot)
        self.viewModel.updateTimeSlot(atIndex: 0, withCategory: .commute)
        
        expect(self.mockMetricsService.didLog(event: .timeSlotEditing)).to(beTrue())
    }
    
    func testTheNewlyAddedSlotHasNoEndTime()
    {
        let timeSlot = TimeSlot(category: .work)
        self.mockPersistencyService.addNewTimeSlot(timeSlot)
        let lastSlot = viewModel.timeSlots.last!
        
        expect(lastSlot.endTime).to(beNil())
    }
    
    func testTheAddNewSlotsMethodEndsThePreviousTimeSlot()
    {
        let timeSlot = TimeSlot(category: .work)
        self.mockPersistencyService.addNewTimeSlot(timeSlot)
        let firstSlot = viewModel.timeSlots.first!
        
        let otherTimeSlot = TimeSlot(category: .work)
        self.mockPersistencyService.addNewTimeSlot(otherTimeSlot)
        
        expect(firstSlot.endTime).toNot(beNil())
    }
    
    func testTheUpdateTimeSlotMethodChangesATimeSlotsCategory()
    {
        let timeSlot = TimeSlot(category: .work)
        self.mockPersistencyService.addNewTimeSlot(timeSlot)
        self.viewModel.updateTimeSlot(atIndex: 0, withCategory: .commute)

        expect(timeSlot.category).to(equal(Category.commute))
    }
}
