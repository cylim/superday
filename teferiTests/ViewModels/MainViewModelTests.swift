import RxSwift
import XCTest
import Nimble
@testable import teferi

class MainViewModelTests : XCTestCase
{
    private var viewModel : MainViewModel!
    private var disposable : Disposable? = nil
    
    private var timeService : MockTimeService!
    private var metricsService : MockMetricsService!
    private var appStateService : MockAppStateService!
    private var feedbackService : MockFeedbackService!
    private var locationService : MockLocationService!
    private var settingsService : MockSettingsService!
    private var timeSlotService : MockTimeSlotService!
    private var editStateService : MockEditStateService!
    private var smartGuessService : MockSmartGuessService!
    private var selectedDateService : MockSelectedDateService!
    
    override func setUp()
    {
        self.timeService = MockTimeService()
        self.metricsService = MockMetricsService()
        self.appStateService = MockAppStateService()
        self.locationService = MockLocationService()
        self.settingsService = MockSettingsService()
        self.feedbackService = MockFeedbackService()
        self.editStateService = MockEditStateService()
        self.smartGuessService = MockSmartGuessService()
        self.selectedDateService = MockSelectedDateService()
        self.timeSlotService = MockTimeSlotService(timeService: self.timeService)
        
        self.viewModel = MainViewModel(timeService: self.timeService,
                                       metricsService: self.metricsService,
                                       appStateService: self.appStateService,
                                       feedbackService: self.feedbackService,
                                       settingsService: self.settingsService,
                                       timeSlotService: self.timeSlotService,
                                       locationService: self.locationService,
                                       editStateService: self.editStateService,
                                       smartGuessService: self.smartGuessService,
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
        
        self.disposable = self.timeSlotService.timeSlotCreatedObservable.subscribe(onNext: { _ in didAdd = true })
        self.viewModel.addNewSlot(withCategory: .commute)
        
        expect(didAdd).to(beTrue())
    }
    
    func testTheAddNewSlotMethodCallsTheMetricsService()
    {
        self.viewModel.addNewSlot(withCategory: .commute)
        expect(self.metricsService.didLog(event: .timeSlotManualCreation)).to(beTrue())
    }
    
    func testTheUpdateMethodCallsTheMetricsService()
    {
        let timeSlot = self.createTimeSlot(withCategory: .work)
        self.timeSlotService.add(timeSlot: timeSlot)
        self.viewModel.updateTimeSlot(timeSlot, withCategory: .commute)
        
        expect(self.metricsService.didLog(event: .timeSlotEditing)).to(beTrue())
    }
    
    func testTheUpdateTimeSlotMethodChangesATimeSlotsCategory()
    {
        let timeSlot = self.createTimeSlot(withCategory: .work)
        self.timeSlotService.add(timeSlot: timeSlot)
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
        self.timeSlotService.add(timeSlot: timeSlot)
        self.viewModel.updateTimeSlot(timeSlot, withCategory: .commute)
        
        expect(editingEnded).to(beTrue())
    }
    
    func testThePermissionStateShouldNotBeShownIfTheUserHasAlreadyAuthorized()
    {
        self.settingsService.hasLocationPermission = true
        
        var wouldShow : Bool? = nil
        self.disposable = self.viewModel
            .overlayStateObservable
            .subscribe(onNext:  { shouldShow in wouldShow = shouldShow })
        
        expect(wouldShow).to(beFalse())
    }
    
    func testIfThePermissionOverlayWasNeverShownItNeedsToBeShown()
    {
        self.settingsService.hasLocationPermission = false
        self.settingsService.lastAskedForLocationPermission = nil
        
        var wouldShow : Bool? = nil
        self.disposable = self.viewModel
            .overlayStateObservable
            .subscribe(onNext: { shouldShow in wouldShow = shouldShow })
        
        expect(wouldShow).to(beTrue())
    }
    
    func testThePermissionStateShouldBeShownIfItWasNotShownForOver24Hours()
    {
        self.settingsService.hasLocationPermission = false
        self.settingsService.lastAskedForLocationPermission = Date().add(days: -2)
        
        var wouldShow : Bool? = nil
        self.disposable = self.viewModel
            .overlayStateObservable
            .subscribe(onNext:  { shouldShow in wouldShow = shouldShow })
        
        expect(wouldShow).to(beTrue())
    }
    
    func testThePermissionStateShouldNotBeShownIfItWasLastShownInTheLast24Hours()
    {
        self.settingsService.hasLocationPermission = false
        self.settingsService.lastAskedForLocationPermission = Date().ignoreTimeComponents()
        
        var wouldShow : Bool? = nil
        self.disposable = self.viewModel
            .overlayStateObservable
            .subscribe(onNext:  { shouldShow in wouldShow = shouldShow })
        
        expect(wouldShow).to(beFalse())
    }
    
    private func createTimeSlot(withCategory category: teferi.Category) -> TimeSlot
    {
        return  TimeSlot(withStartTime: Date(), category: category, categoryWasSetByUser: false)
    }
}
