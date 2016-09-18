import Foundation
import XCTest
import RxSwift
@testable import teferi

class TimelineViewModelTests : XCTestCase
{
    private var disposable : Disposable? = nil
    private var mockPersistencyService = MockPersistencyService()
    private var viewModel = TimelineViewModel(date: Date(), persistencyService: MockPersistencyService())
    
    override func setUp()
    {
        mockPersistencyService = MockPersistencyService()
        viewModel = TimelineViewModel(date: Date(), persistencyService: mockPersistencyService)
    }
    
    override func tearDown()
    {
        disposable?.dispose()
    }
    
    func testTheAddNewSlotsMethodAddsANewSlot()
    {
        let oldSlotCount = viewModel.timeSlots.count
        viewModel.addNewSlot(withCategory: .Commute)
        let newSlotCount = viewModel.timeSlots.count
        
        XCTAssertEqual(newSlotCount, oldSlotCount + 1)
    }
    
    func testTheNewlyAddedSlotHasNoEndTime()
    {
        viewModel.addNewSlot(withCategory: .Commute)
        let lastSlot = viewModel.timeSlots.last!
        
        XCTAssertNil(lastSlot.endTime)
    }
    
    func testTheAddNewSlotsMethodEndsThePreviousTimeSlot()
    {
        viewModel.addNewSlot(withCategory: .Commute)
        let firstSlot = viewModel.timeSlots.first!
        viewModel.addNewSlot(withCategory: .Work)
        
        XCTAssertNotNil(firstSlot.endTime)
    }
}
