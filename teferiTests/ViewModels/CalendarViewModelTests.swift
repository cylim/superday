import Foundation
import XCTest
import RxSwift
import Nimble
@testable import teferi

class CalendarViewModelTests : XCTestCase
{
    private var viewModel : CalendarViewModel!
    private var settingsService : SettingsService!
    private var mockTimeSlotService : MockTimeSlotService!
    private var selectedDateService : SelectedDateService!
    
    override func setUp()
    {
        super.setUp()
        
        self.settingsService = MockSettingsService()
        self.mockTimeSlotService = MockTimeSlotService()
        self.selectedDateService = DefaultSelectedDateService()
        
        self.viewModel = CalendarViewModel(settingsService: self.settingsService,
                                           timeSlotService: self.mockTimeSlotService,
                                           selectedDateService: self.selectedDateService)
    }
}
