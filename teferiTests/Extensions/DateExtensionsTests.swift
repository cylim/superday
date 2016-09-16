import Foundation
import XCTest
import Nimble
@testable import teferi

class DateExtensionsTests : XCTestCase
{
    fileprivate var calendar = Calendar.current
    
    override func setUp()
    {
        calendar = Calendar.current
        
    }
    
    func testTheAddDaysMethodAddsNDaysToTheCurrentDate()
    {
        var components = DateComponents()
        components.day = 10
        components.month = 10
        components.year = 2016
        let octoberTen = calendar.date(from: components)!
        let octoberEleven = octoberTen.addDays(1)
        
        let newComponents = (calendar as Calendar).components(.day, from: octoberEleven)
        expect(newComponents.day).to(equal(11))
    }
    
    func testTheAddDaysMethodRemovesDaysFromTheCurrentDateIfTheParameterIsNegative()
    {
        var components = DateComponents()
        components.day = 10
        components.month = 10
        components.year = 2016
        let octoberTen = calendar.date(from: components)!
        let octoberNine = octoberTen.addDays(-1)
        
        let newComponents = (calendar as Calendar).components(.day, from: octoberNine)
        expect(newComponents.day).to(equal(9))
    }
    
    
    func testTheAddDaysMethodWorksEvenOnTheEndOfMonth()
    {
        var components = DateComponents()
        components.day = 31
        components.month = 10
        components.year = 2016
        let halloween = calendar.date(from: components)!
        let novemberFirst = halloween.addDays(1)
        
        let newComponents = (calendar as Calendar).components([.day, .month], from: novemberFirst)
        
        expect(newComponents.day).to(equal(1))
        expect(newComponents.month).to(equal(11))
    }
    
    func testTheIgnoreTimeComponentsMethodReturnOnlyTheDatePortionOfADate()
    {
        var components = DateComponents()
        components.day = 31
        components.month = 10
        components.year = 2016
        components.hour = 12
        let date = calendar.date(from: components)!
        
        var components2 = DateComponents()
        components2.day = 31
        components2.month = 10
        components2.year = 2016
        components.hour = 13
        let date2 = calendar.date(from: components2)!
        
        expect(date.ignoreTimeComponents() == date2.ignoreTimeComponents()).to(beTrue())
    }
}
