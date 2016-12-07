import Foundation
import XCTest
import RxSwift
import Nimble
@testable import teferi

class CalendarViewModelTests : XCTestCase
{
    
    private var viewModel : CalendarViewModel!
    private var mockTimeSlotService : MockTimeSlotService!
    private var disposable : Disposable? = nil
    
    override func setUp()
    {
        super.setUp()
        self.mockTimeSlotService = MockTimeSlotService()
        self.viewModel = CalendarViewModel(timeSlotService: self.mockTimeSlotService)
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    func testGettingCategoriesSlotsSorted()
    {
        let categoriesOrder = [Category.commute, Category.food, Category.friends, Category.work, Category.leisure]
        
        self.addTimeSlot(withCategory: .unknown)
        self.addTimeSlot(withCategory: .commute)
        self.addTimeSlot(withCategory: .food)
        self.addTimeSlot(withCategory: .friends)
        self.addTimeSlot(withCategory: .work)
        self.addTimeSlot(withCategory: .leisure)
        let slots = self.viewModel.getCategoriesSlots(date: Date())
        
        expect(slots.count).to(equal(5))
        for category in categoriesOrder
        {
            var numberOfOccurences = 0
            for slot in slots
            {
                if slot.category == category
                {
                    numberOfOccurences += 1
                }
            }
            
            expect(numberOfOccurences).to(equal(1))
        }
    }
    
    func testGettingCategoriesSlotsUnsorted()
    {
        self.addTimeSlot(withCategory: .work)
        self.addTimeSlot(withCategory: .friends)
        self.addTimeSlot(withCategory: .work)
        self.addTimeSlot(withCategory: .commute)
        
        let slots = self.viewModel.getCategoriesSlots(date: Date())
        expect(slots.count).to(equal(3))
    }
    
    private func addTimeSlot(withCategory category: teferi.Category)
    {
        let timeSlot = TimeSlot(withStartTime: Date(), category: category, categoryWasSetByUser: false)
        self.mockTimeSlotService.add(timeSlot: timeSlot)
    }
}
