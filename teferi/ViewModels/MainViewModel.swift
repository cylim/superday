import Foundation
import RxSwift

///ViewModel for the MainViewController.
class MainViewModel
{
    // MARK: Fields
    private let superday = "Superday"
    private let superyesterday = "Superyesterday"
    
    private let metricsService : MetricsService
    private let feedbackService: FeedbackService
    private let timeSlotService : TimeSlotService
    private let settingsService : SettingsService
    private let locationService : LocationService
    private let editStateService : EditStateService
    
    init(metricsService: MetricsService,
         feedbackService: FeedbackService,
         settingsService: SettingsService,
         timeSlotService: TimeSlotService,
         locationService : LocationService,
         editStateService: EditStateService)
    {
        self.metricsService = metricsService
        self.feedbackService = feedbackService
        self.settingsService = settingsService
        self.timeSlotService = timeSlotService
        self.locationService = locationService
        self.editStateService = editStateService
    }
    
    // MARK: Properties
    var currentDate = Date()
    
    var shouldShowLocationPermissionOverlay : Bool
    {
        if self.settingsService.hasLocationPermission { return false }
        
        //If user doesn't have permissions and we never showed the overlay, do it
        guard let lastRequestedDate = self.settingsService.lastAskedForLocationPermission else { return true }
        
        let minimumRequestDate = lastRequestedDate.add(days: 1)
        
        //If we previously showed the overlay, we must only do it again after 24 hours
        return minimumRequestDate < Date()
    }
    
    ///Current date for the calendar button
    var calendarDay : String
    {
        let currentDay = Calendar.current.component(.day, from: Date())
        return String(format: "%02d", currentDay)
    }
    
    ///Gets the title for the header. Changes on new locations.
    var title : String
    {
        let today = Date().ignoreTimeComponents()
        let yesterday = today.yesterday.ignoreTimeComponents()
        
        if currentDate.ignoreTimeComponents() == today
        {
            return superday.translate()
        }
        else if currentDate.ignoreTimeComponents() == yesterday
        {
            return superyesterday.translate()
        }
        
        let dayOfMonthFormatter = DateFormatter();
        dayOfMonthFormatter.timeZone = TimeZone.autoupdatingCurrent;
        dayOfMonthFormatter.dateFormat = "dd MMMM";
        
        return dayOfMonthFormatter.string(from: currentDate)
    }
    
    //MARK: Methods
    
    /**
     Adds and persists a new TimeSlot to this Timeline.
     
     - Parameter category: Category of the newly created TimeSlot.
     */
    func addNewSlot(withCategory category: Category)
    {
        let currentLocation = self.locationService.getLastKnownLocation()
        
        let newSlot = TimeSlot(withStartTime: Date(),
                               category: category,
                               location: currentLocation,
                               categoryWasSetByUser: true)
        
        self.timeSlotService.add(timeSlot: newSlot)
        self.metricsService.log(event: .timeSlotManualCreation)
        
        //TODO: Create a smart guess if the location is valid
    }
    
    /**
     Updates a TimeSlot's category.
     
     - Parameter timeSlot: TimeSlot to be updated.
     - Parameter category: Category of the newly created TimeSlot.
     */
    func updateTimeSlot(_ timeSlot: TimeSlot, withCategory category: Category)
    {
        self.timeSlotService.update(timeSlot: timeSlot, withCategory: category)
        self.metricsService.log(event: .timeSlotEditing)
        
        timeSlot.category = category
        
        self.editStateService.notifyEditingEnded()
        
        //TODO: Create a smart guess if the timeSlot has a location and was unknown
        //TODO: Strike a smart guess if the user changed it
    }
}
