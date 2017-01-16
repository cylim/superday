import UIKit
import Foundation
@testable import teferi

class MockLocator : ViewModelLocator
{
    var timeService = MockTimeService()
    var metricsService = MockMetricsService()
    var timeSlotService : MockTimeSlotService
    var appStateService = MockAppStateService()
    var feedbackService = MockFeedbackService()
    var settingsService = MockSettingsService()
    var locationService = MockLocationService()
    var editStateService = MockEditStateService()
    var smartGuessService = MockSmartGuessService()
    var selectedDateService = MockSelectedDateService()
    
    init()
    {
        self.timeSlotService = MockTimeSlotService(timeService: self.timeService)
    }
    
    func getMainViewModel(forViewController viewController: UIViewController) -> MainViewModel
    {
        return MainViewModel(timeService: self.timeService,
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
    
    func getPagerViewModel() -> PagerViewModel
    {
        return PagerViewModel(timeService: self.timeService,
                              appStateService: self.appStateService,
                              settingsService: self.settingsService,
                              editStateService: self.editStateService,
                              selectedDateService: self.selectedDateService)
    }
    
    func getTimelineViewModel(forDate date: Date) -> TimelineViewModel
    {
        return TimelineViewModel(date: date,
                                 timeService: self.timeService,
                                 metricsService: self.metricsService,
                                 appStateService: self.appStateService,
                                 timeSlotService: self.timeSlotService,
                                 editStateService: self.editStateService)
    }
    
    func getCalendarViewModel() -> CalendarViewModel
    {
        return CalendarViewModel(timeService: self.timeService,
                                 settingsService: self.settingsService,
                                 timeSlotService: self.timeSlotService,
                                 selectedDateService: self.selectedDateService)
    }
}
