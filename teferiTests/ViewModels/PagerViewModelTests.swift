import XCTest
@testable import teferi

class PagerViewModelTests : XCTestCase
{
    //MARK: Fields
    private var viewModel = PagerViewModel(settingsService: MockSettingsService())
    private var settingsService = MockSettingsService()
    
    override func setUp()
    {
        self.settingsService = MockSettingsService()
        self.viewModel = PagerViewModel(settingsService: self.settingsService)
    }
    
    func testTheViewModelCanNotAllowScrollsAfterTheCurrentDate()
    {
        let tomorrow = Date().tomorrow
        
        XCTAssertFalse(viewModel.canScroll(toDate: tomorrow))
    }
    
    func testTheViewModelCanNotAllowScrollsToDatesBeforeTheAppInstall()
    {
        let appInstallDate = Date().yesterday
        settingsService.setInstallDate(date: appInstallDate)
        
        let theDayBeforeInstallDate = appInstallDate.yesterday
        
        XCTAssertFalse(viewModel.canScroll(toDate: theDayBeforeInstallDate))
    }
    
    func testTheViewModelAllowsScrollsToDatesAfterTheAppWasInstalledAndBeforeTheCurrentDate()
    {
        let appInstallDate = Date().add(days: -3)
        settingsService.setInstallDate(date: appInstallDate)
        
        let theDayAfterInstallDate = appInstallDate.tomorrow
        
        XCTAssertTrue(viewModel.canScroll(toDate: theDayAfterInstallDate))
    }
}
