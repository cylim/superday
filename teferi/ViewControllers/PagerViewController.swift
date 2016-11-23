import UIKit
import RxSwift

class PagerViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
    // MARK: Fields
    private var disposeBag : DisposeBag? = DisposeBag()
    
    private var metricsService : MetricsService!
    private var appStateService : AppStateService!
    private var settingsService : SettingsService!
    private var timeSlotService : TimeSlotService!
    private var editStateService : EditStateService!
    
    private var currentDateViewController : TimelineViewController!
    
    private var viewModel : PagerViewModel!
    
    // MARK: Properties
    var dateObservable : Observable<Date> { return viewModel.dateObservable }
    
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
                _ editStateService: EditStateService)
    {
        self.metricsService = metricsService
        self.appStateService = appStateService
        self.settingsService = settingsService
        self.timeSlotService = timeSlotService
        self.editStateService = editStateService
        
        self.viewModel = PagerViewModel(settingsService: settingsService)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        self.view.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.disposeBag = self.disposeBag ?? DisposeBag()
        
        self.editStateService
            .isEditingObservable
            .subscribe(onNext: onEditChanged)
            .addDisposableTo(disposeBag!)
        
        self.appStateService
            .appStateObservable
            .subscribe(onNext: self.onAppStateChanged)
            .addDisposableTo(disposeBag!)
        
        self.initCurrentDateViewController()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        self.disposeBag = nil
    }
    
    // MARK: Methods    
    private func initCurrentDateViewController()
    {
        self.currentDateViewController =
            TimelineViewController(date: Date(),
                                   metricsService: self.metricsService,
                                   timeSlotService: self.timeSlotService,
                                   editStateService: self.editStateService)
        
        self.setViewControllers(
            [ currentDateViewController ],
            direction: .forward,
            animated: false,
            completion: nil)
    }
    
    private func onEditChanged(_ isEditing: Bool)
    {
        self.view
            .subviews
            .flatMap { v in v as? UIScrollView }
            .forEach { scrollView in scrollView.isScrollEnabled = !isEditing }
    }
    
    private func onAppStateChanged(appState: AppState)
    {
        if appState == .active
        {
            let today = Date().ignoreTimeComponents()
            
            guard let inactiveDate = self.settingsService.lastInactiveDate, today > inactiveDate.ignoreTimeComponents() else { return }
            
            self.settingsService.setLastInactiveDate(nil)
            self.initCurrentDateViewController()
        }
        else
        {
            self.settingsService.setLastInactiveDate(Date())
        }
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
        
        self.viewModel.date = timelineController.date
    }
    
    // MARK: UIPageViewControllerDataSource implementation
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        let timelineController = viewController as! TimelineViewController
        let nextDate = timelineController.date.yesterday
        
        guard self.viewModel.canScroll(toDate: nextDate) else { return nil }
        
        return TimelineViewController(date: nextDate,
                                      metricsService: self.metricsService,
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
                                      timeSlotService: self.timeSlotService,
                                      editStateService: self.editStateService)
    }
}
