import Foundation
import XCTest
import RxSwift
@testable import teferi

class TimelineViewModelTests : XCTestCase
{
    private var disposable : Disposable? = nil
    private var mockPersistencyService = MockPersistencyService()
    private var mockMetricsService = MockMetricsService()
    private var viewModel = TimelineViewModel(date: Date(),
                                              persistencyService: MockPersistencyService(),
                                              metricsService: MockMetricsService())

    override func setUp()
    {
        mockPersistencyService = MockPersistencyService()
        mockMetricsService = MockMetricsService()
        viewModel = TimelineViewModel(date: Date(),
                                      persistencyService: mockPersistencyService,
                                      metricsService: mockMetricsService)
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
                              persistencyService: newMockPersistencyService,
                              metricsService: mockMetricsService)
        
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
