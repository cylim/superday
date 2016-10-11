import RxSwift
import XCTest
import Nimble
@testable import teferi

class MainViewModelTests : XCTestCase
{
    private var viewModel : MainViewModel!
    private var disposable : Disposable? = nil
    private var mockMetricsService : MockMetricsService!
    private var mockPersistencyService : MockPersistencyService!
    
    override func setUp()
    {
        self.mockMetricsService = MockMetricsService()
        self.mockPersistencyService = MockPersistencyService()
        self.viewModel = MainViewModel(persistencyService: self.mockPersistencyService, metricsService: self.mockMetricsService)
    }
    
    override func tearDown()
    {
        self.disposable?.dispose()
    }
    
    func testTheTitlePropertyReturnsSuperdayForTheCurrentDate()
    {
        let today = Date()
        self.viewModel.currentDate = today
        
        expect(self.viewModel.title).to(equal("Superday".translate()))
    }
    
    func testTheTitlePropertyReturnsSuperyesterdayForYesterday()
    {
        let yesterday = Date().yesterday
        self.viewModel.currentDate = yesterday
        expect(self.viewModel.title).to(equal("Superyesterday".translate()))
    }
    
    func testTheTitlePropertyReturnsTheFormattedDayAndMonthForOtherDates()
    {
        let olderDate = Date().add(days: -2)
        self.viewModel.currentDate = olderDate
        
        let formatter = DateFormatter();
        formatter.timeZone = TimeZone.autoupdatingCurrent;
        formatter.dateFormat = "dd MMMM";
        let expectedText = formatter.string(from: olderDate)
        
        expect(self.viewModel.title).to(equal(expectedText))
    }
    
    func testTheAddNewSlotsMethodAddsANewSlot()
    {
        var didAdd = false
        
        self.mockPersistencyService.subscribeToTimeSlotChanges { _ in didAdd = true }
        self.viewModel.addNewSlot(withCategory: .commute)
        
        expect(didAdd).to(beTrue())
    }
    
    func testTheAddNewSlotMethodCallsTheMetricsService()
    {
        self.viewModel.addNewSlot(withCategory: .commute)
        expect(self.mockMetricsService.didLog(event: .timeSlotManualCreation)).to(beTrue())
    }
}
