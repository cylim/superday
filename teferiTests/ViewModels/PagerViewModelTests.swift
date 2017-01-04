import XCTest
import Nimble
@testable import teferi

class PagerViewModelTests : XCTestCase
{
    //MARK: Fields
    private var viewModel : PagerViewModel!
    private var timeService : TimeService!
    private var appStateService : AppStateService!
    private var settingsService : SettingsService!
    private var editStateService : EditStateService!
    private var selectedDateService : SelectedDateService!
    
    override func setUp()
    {
        self.timeService = MockTimeService()
        self.appStateService = MockAppStateService()
        self.settingsService = MockSettingsService()
        self.editStateService = MockEditStateService()
        self.selectedDateService = MockSelectedDateService()
        
        self.viewModel = PagerViewModel(timeService: self.timeService,
                                        appStateService: self.appStateService,
                                        settingsService: self.settingsService,
                                        editStateService: self.editStateService,
                                        selectedDateService: self.selectedDateService)
    }
    
    func testTheViewModelCanNotAllowScrollsAfterTheCurrentDate()
    {
        let tomorrow = Date().tomorrow
        
        expect(self.viewModel.canScroll(toDate: tomorrow)).to(beFalse())
    }
    
    func testTheViewModelCanNotAllowScrollsToDatesBeforeTheAppInstall()
    {
        let appInstallDate = Date().yesterday
        self.settingsService.setInstallDate(appInstallDate)
        
        let theDayBeforeInstallDate = appInstallDate.yesterday
        
        expect(self.viewModel.canScroll(toDate: theDayBeforeInstallDate)).to(beFalse())
    }
    
    func testTheViewModelAllowsScrollsToDatesAfterTheAppWasInstalledAndBeforeTheCurrentDate()
    {
        let appInstallDate = Date().add(days: -3)
        self.settingsService.setInstallDate(appInstallDate)
        
        let theDayAfterInstallDate = appInstallDate.tomorrow
        
        expect(self.viewModel.canScroll(toDate: theDayAfterInstallDate)).to(beTrue())
    }
}
