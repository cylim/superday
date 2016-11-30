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
        let categoriesOrder = [Category.commute, Category.food,
                                           Category.friends, Category.work, Category.leisure]
        var timeSlot = TimeSlot(category: .unknown)
        self.mockTimeSlotService.add(timeSlot: timeSlot)
        timeSlot = TimeSlot(category: .commute)
        self.mockTimeSlotService.add(timeSlot: timeSlot)
        timeSlot = TimeSlot(category: .food)
        self.mockTimeSlotService.add(timeSlot: timeSlot)
        timeSlot = TimeSlot(category: .food)
        timeSlot = TimeSlot(category: .friends)
        self.mockTimeSlotService.add(timeSlot: timeSlot)
        timeSlot = TimeSlot(category: .work)
        self.mockTimeSlotService.add(timeSlot: timeSlot)
        timeSlot = TimeSlot(category: .leisure)
        self.mockTimeSlotService.add(timeSlot: timeSlot)
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
               } else
               {
                
               }
            }
            expect(numberOfOccurences).to(equal(1))
        }
    }
    
    func testGettingCategoriesSlotsUnsorted()
    {
        var timeSlot = TimeSlot(category: .work)
        self.mockTimeSlotService.add(timeSlot: timeSlot)
        timeSlot = TimeSlot(category: .friends)
        self.mockTimeSlotService.add(timeSlot: timeSlot)
        timeSlot = TimeSlot(category: .work)
        self.mockTimeSlotService.add(timeSlot: timeSlot)
        timeSlot = TimeSlot(category: .commute)
        self.mockTimeSlotService.add(timeSlot: timeSlot)
        let slots = self.viewModel.getCategoriesSlots(date: Date())
        expect(slots.count).to(equal(3))
    }

}
