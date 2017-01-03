import RxSwift
import XCTest
import Nimble
@testable import teferi

class MainViewModelTests : XCTestCase
{
    private var viewModel : MainViewModel!
    private var disposable : Disposable? = nil
    
    private var timeService : TimeService!
    private var editStateService : EditStateService!
    private var mockMetricsService : MockMetricsService!
    private var mockFeedbackService: MockFeedbackService!
    private var mockLocationService : MockLocationService!
    private var mockSettingsService : MockSettingsService!
    private var mockTimeSlotService : MockTimeSlotService!
    private var selectedDateService : SelectedDateService!
    private var mockSmartGuessService : MockSmartGuessService!
    
    override func setUp()
    {
        self.timeService = MockTimeService()
        self.mockMetricsService = MockMetricsService()
        self.mockLocationService = MockLocationService()
        self.mockSettingsService = MockSettingsService()
        self.mockTimeSlotService = MockTimeSlotService()
        self.mockFeedbackService = MockFeedbackService()
        self.mockSmartGuessService = MockSmartGuessService()
        self.editStateService = DefaultEditStateService(timeService: self.timeService)
        self.selectedDateService = DefaultSelectedDateService(timeService: self.timeService)
        
        self.viewModel = MainViewModel(timeService: self.timeService,
                                       metricsService: self.mockMetricsService,
                                       feedbackService: self.mockFeedbackService,
                                       settingsService: self.mockSettingsService,
                                       timeSlotService: self.mockTimeSlotService,
                                       locationService: self.mockLocationService,
                                       editStateService: self.editStateService,
                                       smartGuessService: self.mockSmartGuessService,
                                       selectedDateService: self.selectedDateService)
    }
    
    override func tearDown()
    {
        self.disposable?.dispose()
    }
    
    func testTheTitlePropertyReturnsSuperdayForTheCurrentDate()
    {
        let today = Date()
        self.selectedDateService.currentlySelectedDate = today
        
        expect(self.viewModel.title).to(equal("CurrentDayBarTitle".translate()))
    }
    
    func testTheTitlePropertyReturnsSuperyesterdayForYesterday()
    {
        let yesterday = Date().yesterday
        self.selectedDateService.currentlySelectedDate = yesterday
        expect(self.viewModel.title).to(equal("YesterdayBarTitle".translate()))
    }
    
    func testTheTitlePropertyReturnsTheFormattedDayAndMonthForOtherDates()
    {
        let olderDate = Date().add(days: -2)
        self.selectedDateService.currentlySelectedDate = olderDate
        
        let formatter = DateFormatter();
        formatter.timeZone = TimeZone.autoupdatingCurrent;
        formatter.dateFormat = "EEE, dd MMM";
        let expectedText = formatter.string(from: olderDate)
        
        expect(self.viewModel.title).to(equal(expectedText))
    }
    
    func testTheAddNewSlotsMethodAddsANewSlot()
    {
        var didAdd = false
        
        self.mockTimeSlotService.subscribeToTimeSlotChanges(on: .create, { _ in didAdd = true })
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
        let timeSlot = self.createTimeSlot(withCategory: .work)
        self.mockTimeSlotService.add(timeSlot: timeSlot)
        self.viewModel.updateTimeSlot(timeSlot, withCategory: .commute)
        
        expect(self.mockMetricsService.didLog(event: .timeSlotEditing)).to(beTrue())
    }
    
    func testTheUpdateTimeSlotMethodChangesATimeSlotsCategory()
    {
        let timeSlot = self.createTimeSlot(withCategory: .work)
        self.mockTimeSlotService.add(timeSlot: timeSlot)
        self.viewModel.updateTimeSlot(timeSlot, withCategory: .commute)
        
        expect(timeSlot.category).to(equal(Category.commute))
    }
    
    func testTheUpdateTimeSlotMethodEndsTheEditingProcess()
    {
        var editingEnded = false
        _ = self.editStateService
            .isEditingObservable
            .subscribe(onNext: { editingEnded = !$0 })
        
        let timeSlot = self.createTimeSlot(withCategory: .work)
        self.mockTimeSlotService.add(timeSlot: timeSlot)
        self.viewModel.updateTimeSlot(timeSlot, withCategory: .commute)
        
        expect(editingEnded).to(beTrue())
    }
    
    func testThePermissionStateShouldNotBeShownIfTheUserHasAlreadyAuthorized()
    {
        self.mockSettingsService.hasLocationPermission = true
        
        let shouldShow = self.viewModel.shouldShowLocationPermissionOverlay
        
        expect(shouldShow).to(beFalse())
    }
    
    func testIfThePermissionOverlayWasNeverShownItNeedsToBeShown()
    {
        self.mockSettingsService.hasLocationPermission = false
        self.mockSettingsService.lastAskedForLocationPermission = nil
        
        let shouldShow = self.viewModel.shouldShowLocationPermissionOverlay
        
        expect(shouldShow).to(beTrue())
    }
    
    func testThePermissionStateShouldBeShownIfItWasNotShownForOver24Hours()
    {
        self.mockSettingsService.hasLocationPermission = false
        self.mockSettingsService.lastAskedForLocationPermission = Date().add(days: -2)
        
        let shouldShow = self.viewModel.shouldShowLocationPermissionOverlay
        
        expect(shouldShow).to(beTrue())
    }
    
    func testThePermissionStateShouldNotBeShownIfItWasLastShownInTheLast24Hours()
    {
        self.mockSettingsService.hasLocationPermission = false
        self.mockSettingsService.lastAskedForLocationPermission = Date().ignoreTimeComponents()
        
        let shouldShow = self.viewModel.shouldShowLocationPermissionOverlay
        
        expect(shouldShow).to(beFalse())
    }
    
    private func createTimeSlot(withCategory category: teferi.Category) -> TimeSlot
    {
        return  TimeSlot(withStartTime: Date(), category: category, categoryWasSetByUser: false)
    }
}
