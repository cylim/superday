import RxSwift
import XCTest
@testable import teferi

class MainViewModelTests : XCTestCase
{
    private var disposable : Disposable? = nil
    private var mockLocationService = MockLocationService()
    private var viewModel = MainViewModel()
    
    override func setUp()
    {
        mockLocationService = MockLocationService()
        viewModel = MainViewModel()
    }
    
    override func tearDown()
    {
        disposable?.dispose()
    }
    
    func testTheTitlePropertyReturnsSuperdayForTheCurrentDate()
    {
        let today = Date()
        viewModel.currentDate = today
        XCTAssertEqual(self.viewModel.title, "Superday".translate())
    }
    
    func testTheTitlePropertyReturnsSuperyesterdayForYesterday()
    {
        let yesterday = Date().yesterday
        viewModel.currentDate = yesterday
        XCTAssertEqual(self.viewModel.title, "Superyesterday".translate())
    }
    
    func testTheTitlePropertyReturnsTheFormattedDayAndMonthForOtherDates()
    {
        let olderDate = Date().add(days: -2)
        viewModel.currentDate = olderDate
        
        let formatter = DateFormatter();
        formatter.timeZone = TimeZone.autoupdatingCurrent;
        formatter.dateFormat = "dd MMMM";
        let expectedText = formatter.string(from: olderDate)
        
        XCTAssertEqual(self.viewModel.title, expectedText)
    }
}
