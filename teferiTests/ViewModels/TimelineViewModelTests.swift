import Nimble
import Foundation
import XCTest
import RxSwift
@testable import teferi

class TimelineViewModelTests : XCTestCase
{
    private var disposable : Disposable? = nil
    private var viewModel = TimelineViewModel(date: NSDate())
    
    override func setUp()
    {
        viewModel = TimelineViewModel(date: NSDate())
    }
    
    override func tearDown()
    {
        disposable?.dispose()
    }
    
    func testTheAddNewSlotsMethodAddsANewSlot()
    {
        let oldSlotCount = viewModel.timeSlots.count
        viewModel.addNewSlot(.Commute)
        let newSlotCount = viewModel.timeSlots.count
        
        expect(newSlotCount).to(equal(oldSlotCount + 1))
    }
    
    func testTheNewlyAddedSlotHasNoEndTime()
    {
        viewModel.addNewSlot(.Commute)
        let lastSlot = viewModel.timeSlots.last!
        
        expect(lastSlot.endTime).to(beNil())
    }
    
    func testTheAddNewSlotsMethodEndsThePreviousTimeSlot()
    {
        viewModel.addNewSlot(.Commute)
        let firstSlot = viewModel.timeSlots.first!
        viewModel.addNewSlot(.Work)
        
        expect(firstSlot.endTime).notTo(beNil())
    }
}