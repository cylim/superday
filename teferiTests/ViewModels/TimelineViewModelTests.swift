import Foundation
import XCTest
import RxSwift
@testable import teferi

class TimelineViewModelTests : XCTestCase
{
    private var disposable : Disposable? = nil
    
    private var viewModel : TimelineViewModel!
    private var mockMetricsService : MockMetricsService!
    private var mockPersistencyService : MockPersistencyService!

    override func setUp()
    {
        mockMetricsService = MockMetricsService()
        mockPersistencyService = MockPersistencyService()
        
        viewModel = TimelineViewModel(date: Date(),
                                      metricsService: mockMetricsService,
                                      persistencyService: mockPersistencyService)
    }
    
    override func tearDown()
    {
        disposable?.dispose()
    }
    
    func testOnlyViewModelsForTheCurrentDaySubscribeForTimeSlotUpdates()
    {
        XCTAssertTrue(self.mockPersistencyService.didSubscribe)
    }
    
    func testViewModelsForTheOlderDaysDoNotSubscribeForTimeSlotUpdates()
    {
        let newMockPersistencyService = MockPersistencyService()
        _ = TimelineViewModel(date: Date().yesterday,
                              metricsService: mockMetricsService,
                              persistencyService: newMockPersistencyService)
        
        XCTAssertFalse(newMockPersistencyService.didSubscribe)
    }
    
    func testTheUpdateMethodCallsTheMetricsService()
    {
        let timeSlot = TimeSlot(category: .work)
        XCTAssertTrue(mockPersistencyService.addNewTimeSlot(timeSlot))
        XCTAssertTrue(viewModel.updateTimeSlot(atIndex: 0, withCategory: .commute))
        XCTAssertTrue(self.mockMetricsService.didLog(event: .timeSlotEditing))
    }
    
    func testTheNewlyAddedSlotHasNoEndTime()
    {
        let timeSlot = TimeSlot(category: .work)
        XCTAssertTrue(mockPersistencyService.addNewTimeSlot(timeSlot))
        let lastSlot = viewModel.timeSlots.last!
        
        XCTAssertNil(lastSlot.endTime)
    }
    
    func testTheAddNewSlotsMethodEndsThePreviousTimeSlot()
    {
        let timeSlot = TimeSlot(category: .work)
        XCTAssertTrue(mockPersistencyService.addNewTimeSlot(timeSlot))
        let firstSlot = viewModel.timeSlots.first!
        
        let otherTimeSlot = TimeSlot(category: .work)
        XCTAssertTrue(mockPersistencyService.addNewTimeSlot(otherTimeSlot))
        
        XCTAssertNotNil(firstSlot.endTime)
    }
    
    func testTheUpdateTimeSlotMethodChangesATimeSlotsCategory()
    {
        let timeSlot = TimeSlot(category: .work)
        XCTAssertTrue(mockPersistencyService.addNewTimeSlot(timeSlot))
        
        XCTAssertTrue(viewModel.updateTimeSlot(atIndex: 0, withCategory: .commute))
        XCTAssertEqual(timeSlot.category, .commute)
    }
}
