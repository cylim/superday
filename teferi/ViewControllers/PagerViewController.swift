import UIKit
import RxSwift

class PagerViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
    // MARK: Fields
    private let lastInactiveDateKey = "lastInactiveDate"
    private var lastInactiveDate : Date?
    {
        get { return UserDefaults.standard.object(forKey: lastInactiveDateKey) as? Date }
        set(value) { UserDefaults.standard.set(value, forKey: lastInactiveDateKey) }
    }
    
    private let dateVariable = Variable(Date())
    private var disposeBag : DisposeBag? = DisposeBag()
    
    private var metricsService : MetricsService!
    private var appStateService : AppStateService!
    private var editStateService : EditStateService!
    private var persistencyService : PersistencyService!
    
    private var currentDateViewController : TimelineViewController!
    
    private var viewModel : PagerViewModel!
    
    // MARK: Properties
    var dateObservable : Observable<Date> { return dateVariable.asObservable() }
    
    // MARK: Initializers
    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]?)
    {
        super.init(transitionStyle: .scroll,
                   navigationOrientation: .horizontal,
                   options: options)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(transitionStyle: .scroll,
                   navigationOrientation: .horizontal,
                   options: nil)
    }
    
    // MARK: UIViewController lifecycle
    
    func inject(_ metricsService: MetricsService,
                _ appStateService: AppStateService,
                _ settingsService: SettingsService,
                _ editStateService: EditStateService,
                _ persistencyService: PersistencyService)
    {
        self.metricsService = metricsService
        self.appStateService = appStateService
        self.editStateService = editStateService
        self.persistencyService = persistencyService
        
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
                                   metricsService: metricsService,
                                   editStateService: editStateService,
                                   persistencyService: persistencyService)
        
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
            
            guard let inactiveDate = lastInactiveDate, today > inactiveDate.ignoreTimeComponents() else { return }
            
            self.lastInactiveDate = nil
            self.initCurrentDateViewController()
        }
        else
        {
            self.lastInactiveDate = Date()
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
        
        self.dateVariable.value = timelineController.date
    }
    
    // MARK: UIPageViewControllerDataSource implementation
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        let timelineController = viewController as! TimelineViewController
        let nextDate = timelineController.date.yesterday
        
        guard self.viewModel.canScroll(toDate: nextDate) else { return nil }
        
        return TimelineViewController(date: nextDate,
                                      metricsService: metricsService,
                                      editStateService: editStateService,
                                      persistencyService: persistencyService)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        let timelineController = viewController as! TimelineViewController
        let nextDate = timelineController.date.tomorrow
        
        guard viewModel.canScroll(toDate: nextDate) else { return nil }
        
        return TimelineViewController(date: nextDate,
                                      metricsService: metricsService,
                                      editStateService: editStateService,
                                      persistencyService: persistencyService)
    }
}
