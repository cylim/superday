import Foundation
import XCTest
import Nimble
@testable import teferi

class DateExtensionsTests : XCTestCase
{
    private var calendar = NSCalendar.currentCalendar()
    
    override func setUp()
    {
        calendar = NSCalendar.currentCalendar()
        
    }
    
    func testTheAddDaysMethodAddsNDaysToTheCurrentDate()
    {
        let components = NSDateComponents()
        components.day = 10
        components.month = 10
        components.year = 2016
        let octoberTen = calendar.dateFromComponents(components)!
        let octoberEleven = octoberTen.addDays(1)
        
        let newComponents = calendar.components(.Day, fromDate: octoberEleven)
        expect(newComponents.day).to(equal(11))
    }
    
    func testTheAddDaysMethodRemovesDaysFromTheCurrentDateIfTheParameterIsNegative()
    {
        let components = NSDateComponents()
        components.day = 10
        components.month = 10
        components.year = 2016
        let octoberTen = calendar.dateFromComponents(components)!
        let octoberNine = octoberTen.addDays(-1)
        
        let newComponents = calendar.components(.Day, fromDate: octoberNine)
        expect(newComponents.day).to(equal(9))
    }
    
    
    func testTheAddDaysMethodWorksEvenOnTheEndOfMonth()
    {
        let components = NSDateComponents()
        components.day = 31
        components.month = 10
        components.year = 2016
        let halloween = calendar.dateFromComponents(components)!
        let novemberFirst = halloween.addDays(1)
        
        let newComponents = calendar.components([.Day, .Month], fromDate: novemberFirst)
        
        expect(newComponents.day).to(equal(1))
        expect(newComponents.month).to(equal(11))
    }
    
    func testTheEqualsDateMethodComparesOnlyTheDatePortion()
    {
        let components = NSDateComponents()
        components.day = 31
        components.month = 10
        components.year = 2016
        components.hour = 12
        let date = calendar.dateFromComponents(components)!
        
        let components2 = NSDateComponents()
        components2.day = 31
        components2.month = 10
        components2.year = 2016
        components.hour = 13
        let date2 = calendar.dateFromComponents(components2)!
        
        expect(date.equalsDate(date2)).to(beTrue())
    }
}