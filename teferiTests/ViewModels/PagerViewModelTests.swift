import XCTest
import Nimble
@testable import teferi

class PagerViewModelTests : XCTestCase
{
    //MARK: Fields
    private var viewModel : PagerViewModel!
    
    private var timeService : TimeService!
    private var settingsService : SettingsService!
    private var selectedDateService : SelectedDateService!
    
    override func setUp()
    {
        self.timeService = MockTimeService()
        self.settingsService = MockSettingsService()
        self.selectedDateService = DefaultSelectedDateService(timeService: self.timeService)
        
        self.viewModel = PagerViewModel(timeService: self.timeService,
                                        settingsService: self.settingsService,
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
