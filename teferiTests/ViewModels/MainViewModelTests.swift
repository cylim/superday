import RxSwift
import XCTest
@testable import teferi

class MainViewModelTests : XCTestCase
{
    private var disposable : Disposable? = nil
    private var mockMetricsService = MockMetricsService()
    private var mockPersistencyService = MockPersistencyService()
    private var viewModel = MainViewModel(persistencyService: MockPersistencyService(), metricsService: MockMetricsService())
    
    override func setUp()
    {
        self.mockPersistencyService = MockPersistencyService()
        self.viewModel = MainViewModel(persistencyService: self.mockPersistencyService, metricsService: self.mockMetricsService)
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
    
    func testTheAddNewSlotsMethodAddsANewSlot()
    {
        var didAdd = false
        
        self.mockPersistencyService.subscribeToTimeSlotChanges { _ in didAdd = true }
        
        viewModel.addNewSlot(withCategory: .commute)
        
        XCTAssertTrue(didAdd)
    }
    
    func testTheAddNewSlotMethodCallsTheMetricsService()
    {
        viewModel.addNewSlot(withCategory: .commute)
        XCTAssertTrue(self.mockMetricsService.didLog(event: .timeSlotManualCreation))
    }
}
