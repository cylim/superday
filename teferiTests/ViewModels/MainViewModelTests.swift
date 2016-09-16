import Nimble
import RxSwift
import XCTest
@testable import teferi

class MainViewModelTests : XCTestCase
{
    fileprivate var disposable : Disposable? = nil
    fileprivate var mockLocationService = MockLocationService()
    fileprivate var viewModel = MainViewModel(locationService: MockLocationService())
    
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
        let today = Date()
        viewModel.date = today
        expect(self.viewModel.title).to(equal("Superday".translate()))
    }
    
    func testTheTitlePropertyReturnsSuperyesterdayForYesterday()
    {
        let yesterday = Date().addDays(-1)
        viewModel.date = yesterday
        expect(self.viewModel.title).to(equal("Superyesterday".translate()))
    }
    
    func testTheTitlePropertyReturnsTheFormattedDayAndMonthForOtherDates()
    {
        
        let olderDate = Date().addDays(-2)
        viewModel.date = olderDate
        
        let formatter = DateFormatter();
        formatter.timeZone = TimeZone.autoupdatingCurrent;
        formatter.dateFormat = "dd MMMM";
        let expectedText = formatter.string(from: olderDate)
        
        expect(self.viewModel.title).to(equal(expectedText))
    }
}
