import Nimble
import RxSwift
import XCTest
@testable import teferi

class MainViewModelTests : XCTestCase
{
    private var disposable : Disposable? = nil
    private var mockLocationService = MockLocationService()
    private var viewModel = MainViewModel(locationService: MockLocationService())
    
    override func setUp()
    {
        mockLocationService = MockLocationService()
        viewModel = MainViewModel(locationService: mockLocationService)
        viewModel.start()
    }
    
    override func tearDown()
    {
        disposable?.dispose()
    }
    
    func testStartMethodSubscribesToTheLocationService()
    {
        expect(self.mockLocationService.didSubscribe).to(equal(true))
    }
    
    func testTheCurrentLocationGetsUpdatedWhenTheLocationServiceBroadcasts()
    {
        var locationChanged = false
        disposable = viewModel.locationObservable.subscribe { location in locationChanged = true }
        let location = Location(latitude: 5, longitude: 5)
        
        self.mockLocationService.setMockLocation(location)
        expect(locationChanged).to(beTrue())
    }
    
    func testTheTitlePropertyReturnsSuperdayForTheCurrentDate()
    {
        let today = NSDate()
        viewModel.date = today
        expect(self.viewModel.title).to(equal("Superday".translate()))
    }
    
    func testTheTitlePropertyReturnsSuperyesterdayForYesterday()
    {
        let yesterday = NSDate().addDays(-1)
        viewModel.date = yesterday
        expect(self.viewModel.title).to(equal("Superyesterday".translate()))
    }
    
    func testTheTitlePropertyReturnsTheFormattedDayAndMonthForOtherDates()
    {
        
        let olderDate = NSDate().addDays(-2)
        viewModel.date = olderDate
        
        let formatter = NSDateFormatter();
        formatter.timeZone = NSTimeZone.localTimeZone();
        formatter.dateFormat = "dd MMMM";
        let expectedText = formatter.stringFromDate(olderDate)
        
        expect(self.viewModel.title).to(equal(expectedText))
    }
}