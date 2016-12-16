import UIKit
import RxSwift

class PagerViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
    // MARK: Fields
    private let disposeBag = DisposeBag()
    
    private var metricsService : MetricsService!
    private var appStateService : AppStateService!
    private var settingsService : SettingsService!
    private var timeSlotService : TimeSlotService!
    private var editStateService : EditStateService!
    private var selectedDateService : SelectedDateService!
    
    private var currentDateViewController : TimelineViewController!
    
    private var viewModel : PagerViewModel!
    
    // MARK: Properties
    var feedbackUIClosing : Bool = false
    
    // MARK: Initializers
    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]?)
    {
        super.init(transitionStyle: .scroll,
                   navigationOrientation: .horizontal,
                   options: options)
    }
    
    required convenience init?(coder: NSCoder)
    {
        self.init(transitionStyle: .scroll,
                  navigationOrientation: .horizontal,
                  options: nil)
    }
    
    // MARK: UIViewController lifecycle
    
    func inject(_ metricsService: MetricsService,
                _ appStateService: AppStateService,
                _ settingsService: SettingsService,
                _ timeSlotService: TimeSlotService,
                _ editStateService: EditStateService,
                _ selectedDateService: SelectedDateService)
    {
        self.metricsService = metricsService
        self.appStateService = appStateService
        self.settingsService = settingsService
        self.timeSlotService = timeSlotService
        self.editStateService = editStateService
        self.selectedDateService = selectedDateService
        
        self.viewModel = PagerViewModel(settingsService: settingsService,
                                        selectedDateService: selectedDateService)
        self.createBindings()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        self.view.backgroundColor = Color.white
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        //TODO: Figure this out
        if !self.feedbackUIClosing
        {
            self.setCurrentViewController(forDate: Date(), animated: false)
        }
        
        self.feedbackUIClosing = false
    }
    
    private func createBindings()
    {
        self.viewModel
            .dateObservable
            .subscribe(onNext: self.onDateChanged)
            .addDisposableTo(self.disposeBag)
        
        self.editStateService
            .isEditingObservable
            .subscribe(onNext: onEditChanged)
            .addDisposableTo(self.disposeBag)
        
        self.appStateService
            .appStateObservable
            .subscribe(onNext: self.onAppStateChanged)
            .addDisposableTo(self.disposeBag)
    }
    
    // MARK: Methods
    private func onEditChanged(_ isEditing: Bool)
    {
        self.view
            .subviews
            .flatMap { v in v as? UIScrollView }
            .forEach { scrollView in scrollView.isScrollEnabled = !isEditing }
    }
    
    private func onDateChanged(_ dateChange: DateChange)
    {
        self.setCurrentViewController(forDate: dateChange.newDate,
                                      animated: true,
                                      moveBackwards: dateChange.newDate < dateChange.oldDate)
    }
    
    private func onAppStateChanged(appState: AppState)
    {
        switch appState
        {
            case .active:
                let today = Date().ignoreTimeComponents()
                
                guard let inactiveDate = self.settingsService.lastInactiveDate, today > inactiveDate.ignoreTimeComponents() else { return }
                
                self.settingsService.setLastInactiveDate(nil)
                self.setCurrentViewController(forDate: Date(), animated: false)
                break
            
            case .inactive:
                self.settingsService.setLastInactiveDate(Date())
                break
            
            case .needsRefreshing:
                self.settingsService.setLastInactiveDate(nil)
                self.setCurrentViewController(forDate: Date(), animated: false)
                break
        }
    }
    
    private func setCurrentViewController(forDate date: Date, animated: Bool, moveBackwards: Bool = false)
    {
        let viewController =
            [ TimelineViewController(date: date,
                                     metricsService: self.metricsService,
                                     appStateService: self.appStateService,
                                     timeSlotService: self.timeSlotService,
                                     editStateService: self.editStateService) ]
        
        self.setViewControllers(viewController, direction: moveBackwards ? .reverse : .forward, animated: animated, completion: nil)
    }
    
    // MARK: UIPageViewControllerDelegate implementation
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        guard completed else { return }
        
        let timelineController = self.viewControllers!.first as! TimelineViewController
        
        if timelineController.date.ignoreTimeComponents() == Date().ignoreTimeComponents()
        {
            self.currentDateViewController = timelineController
        }
        
        self.viewModel.currentlySelectedDate = timelineController.date
    }
    
    // MARK: UIPageViewControllerDataSource implementation
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        let timelineController = viewController as! TimelineViewController
        let nextDate = timelineController.date.yesterday
        
        guard self.viewModel.canScroll(toDate: nextDate) else { return nil }
        
        return TimelineViewController(date: nextDate,
                                      metricsService: self.metricsService,
                                      appStateService: self.appStateService,
                                      timeSlotService: self.timeSlotService,
                                      editStateService: self.editStateService)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        let timelineController = viewController as! TimelineViewController
        let nextDate = timelineController.date.tomorrow
        
        guard self.viewModel.canScroll(toDate: nextDate) else { return nil }
        
        return TimelineViewController(date: nextDate,
                                      metricsService: self.metricsService,
                                      appStateService: self.appStateService,
                                      timeSlotService: self.timeSlotService,
                                      editStateService: self.editStateService)
    }
}
