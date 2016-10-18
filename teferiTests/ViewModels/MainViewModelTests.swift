import RxSwift
import XCTest
import Nimble
@testable import teferi

class MainViewModelTests : XCTestCase
{
    private var viewModel : MainViewModel!
    private var disposable : Disposable? = nil
    private var editStateService : EditStateService!
    private var mockMetricsService : MockMetricsService!
    private var mockPersistencyService : MockPersistencyService!
    
    override func setUp()
    {
        self.mockMetricsService = MockMetricsService()
        self.editStateService = DefaultEditStateService()
        self.mockPersistencyService = MockPersistencyService()
        self.viewModel = MainViewModel(persistencyService: self.mockPersistencyService, editStateService: self.editStateService, metricsService: self.mockMetricsService)
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
    
    func testTheUpdateMethodCallsTheMetricsService()
    {
        let timeSlot = TimeSlot(category: .work)
        self.mockPersistencyService.addNewTimeSlot(timeSlot)
        self.viewModel.updateTimeSlot(timeSlot, withCategory: .commute)
        
        expect(self.mockMetricsService.didLog(event: .timeSlotEditing)).to(beTrue())
    }
    
    func testTheUpdateTimeSlotMethodChangesATimeSlotsCategory()
    {
        let timeSlot = TimeSlot(category: .work)
        self.mockPersistencyService.addNewTimeSlot(timeSlot)
        self.viewModel.updateTimeSlot(timeSlot, withCategory: .commute)
        
        expect(timeSlot.category).to(equal(Category.commute))
    }
    
    func testTheUpdateTimeSlotMethodEndsTheEditingProcess()
    {
        var editingEnded = false
        let observable = self.editStateService
            .isEditingObservable
            .subscribe(onNext: { editingEnded = !$0 })
        
        let timeSlot = TimeSlot(category: .work)
        self.mockPersistencyService.addNewTimeSlot(timeSlot)
        self.viewModel.updateTimeSlot(timeSlot, withCategory: .commute)
        
        expect(editingEnded).to(beTrue())
    }
}
