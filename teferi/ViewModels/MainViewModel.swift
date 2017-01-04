import Foundation
import RxSwift

///ViewModel for the MainViewController.
class MainViewModel
{
    // MARK: Fields
    private let currentDayBarTitle = "CurrentDayBarTitle"
    private let yesterdayBarTitle = "YesterdayBarTitle"
    
    private let timeService : TimeService
    private let metricsService : MetricsService
    private let feedbackService: FeedbackService
    private let appStateService : AppStateService
    private let timeSlotService : TimeSlotService
    private let settingsService : SettingsService
    private let locationService : LocationService
    private let editStateService : EditStateService
    private let smartGuessService : SmartGuessService
    private let selectedDateService : SelectedDateService
    
    init(timeService: TimeService,
         metricsService: MetricsService,
         appStateService: AppStateService,
         feedbackService: FeedbackService,
         settingsService: SettingsService,
         timeSlotService: TimeSlotService,
         locationService : LocationService,
         editStateService: EditStateService,
         smartGuessService : SmartGuessService,
         selectedDateService : SelectedDateService)
    {
        self.timeService = timeService
        self.metricsService = metricsService
        self.appStateService = appStateService
        self.feedbackService = feedbackService
        self.settingsService = settingsService
        self.timeSlotService = timeSlotService
        self.locationService = locationService
        self.editStateService = editStateService
        self.smartGuessService = smartGuessService
        self.selectedDateService = selectedDateService
        
        self.isEditingObservable = self.editStateService.isEditingObservable
        self.beganEditingObservable = self.editStateService.beganEditingObservable
    }
    
    // MARK: Properties
    let isEditingObservable : Observable<Bool>
    let beganEditingObservable : Observable<(CGPoint, TimeSlot)>
    
    private(set) lazy var overlayStateObservable : Observable<Bool> =
    {
        return self.appStateService
          .appStateObservable
          .filter { $0 == .active }
          .map { _ in return self.shouldShowLocationPermissionOverlay }
    }()
    
    // MARK: Properties
    var currentDate : Date { return self.timeService.now }
    
    var dateObservable : Observable<Date> { return self.selectedDateService.currentlySelectedDateObservable}
    
    var canIgnoreLocationPermission : Bool { return self.settingsService.canIgnoreLocationPermission }
    
    private var shouldShowLocationPermissionOverlay : Bool
    {
        if self.settingsService.hasLocationPermission { return false }
        
        //If user doesn't have permissions and we never showed the overlay, do it
        guard let lastRequestedDate = self.settingsService.lastAskedForLocationPermission else { return true }
        
        let minimumRequestDate = lastRequestedDate.add(days: 1)
        
        //If we previously showed the overlay, we must only do it again after 24 hours
        return minimumRequestDate < self.timeService.now
    }
    
    ///Current date for the calendar button
    var currentlySelectedDate : Date { return self.selectedDateService.currentlySelectedDate }
    
    var calendarDay : String
    {
        let currentDay = Calendar.current.component(.day, from: self.timeService.now)
        return String(format: "%02d", currentDay)
    }
    
    ///Gets the title for the header. Changes on new locations.
    var title : String
    {
        let today = self.timeService.now.ignoreTimeComponents()
        let yesterday = today.yesterday.ignoreTimeComponents()
        
        if self.currentlySelectedDate.ignoreTimeComponents() == today
        {
            return self.currentDayBarTitle.translate()
        }
        else if self.currentlySelectedDate.ignoreTimeComponents() == yesterday
        {
            return self.yesterdayBarTitle.translate()
        }
        
        let dayOfMonthFormatter = DateFormatter();
        dayOfMonthFormatter.timeZone = TimeZone.autoupdatingCurrent;
        dayOfMonthFormatter.dateFormat = "EEE, dd MMM";
        
        return dayOfMonthFormatter.string(from: self.currentlySelectedDate)
    }
    
    //MARK: Methods
    
    /**
     Adds and persists a new TimeSlot to this Timeline.
     
     - Parameter category: Category of the newly created TimeSlot.
     */
    
    func addNewSlot(withCategory category: Category)
    {
        self.addNewSlot(withCategory: category, isFirstTimeSlot: false)
    }
    
    func addNewSlot(withCategory category: Category, isFirstTimeSlot: Bool)
    {
        let currentLocation = self.locationService.getLastKnownLocation()
        
        let newSlot = TimeSlot(withStartTime: self.timeService.now,
                               category: category,
                               location: currentLocation,
                               categoryWasSetByUser: !isFirstTimeSlot)
        
        if let location = currentLocation
        {
            self.smartGuessService.add(withCategory: category, location: location)
        }
        
        self.timeSlotService.add(timeSlot: newSlot)
        self.metricsService.log(event: .timeSlotManualCreation)
    }
    
    /**
     Updates a TimeSlot's category.
     
     - Parameter timeSlot: TimeSlot to be updated.
     - Parameter category: Category of the newly created TimeSlot.
     */
    func updateTimeSlot(_ timeSlot: TimeSlot, withCategory category: Category)
    {
        self.timeSlotService.update(timeSlot: timeSlot, withCategory: category, setByUser: true)
        self.metricsService.log(event: .timeSlotEditing)
        
        let smartGuessId = timeSlot.smartGuessId
        if !timeSlot.categoryWasSetByUser && smartGuessId != nil
        {
            //Strike the smart guess if it was wrong
            self.smartGuessService.strike(withId: smartGuessId!)
        }
        else if smartGuessId == nil, let location = timeSlot.location
        {
            self.smartGuessService.add(withCategory: category, location: location)
        }
        
        timeSlot.category = category
        timeSlot.categoryWasSetByUser = true
        
        self.editStateService.notifyEditingEnded()
    }
    
    func composeFeedback(_ completed: @escaping () -> ()) { self.feedbackService.composeFeedback(completed: completed) }
    
    func setLastAskedForLocationPermission() { self.settingsService.setLastAskedForLocationPermission(Date()) }
    
    func setAllowedLocationPermission() { self.settingsService.setAllowedLocationPermission() }
    
    func notifyEditingEnded() { self.editStateService.notifyEditingEnded() }
}
