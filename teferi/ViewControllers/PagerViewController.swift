import UIKit
import RxSwift

class PagerViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
    // MARK: Fields
    private let dateVariable = Variable(Date())
    private var disposeBag : DisposeBag? = DisposeBag()
    
    private var metricsService : MetricsService!
    private var isEditingVariable : Variable<Bool>!
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
    
    func inject(_ metricsService: MetricsService, _ settingsService: SettingsService, _ persistencyService: PersistencyService, _ isEditingVariable: Variable<Bool>)
    {
        self.metricsService = metricsService
        self.isEditingVariable = isEditingVariable
        self.persistencyService = persistencyService
        
        viewModel = PagerViewModel(settingsService: settingsService)
        
        currentDateViewController = TimelineViewController(date: Date(),
                                                           metricsService: metricsService,
                                                           persistencyService: persistencyService,
                                                           isEditingVariable: isEditingVariable)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        delegate = self
        dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        disposeBag = disposeBag ?? DisposeBag()
        
        self.isEditingVariable
            .asObservable()
            .subscribe(onNext: onEditChanged)
            .addDisposableTo(disposeBag!)
        
        setViewControllers(
            [ currentDateViewController ],
            direction: .forward,
            animated: false,
            completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        disposeBag = nil
    }
    
    // MARK: Methods    
    private func onEditChanged(_ isEditing: Bool)
    {
        self.view.subviews.filter { v in v is UIScrollView }.forEach
        {
            view in
            
            let scrollView = view as! UIScrollView
            scrollView.isScrollEnabled = !isEditing
        }
    }
    
    // MARK: UIPageViewControllerDelegate implementation
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        guard completed else { return }
        
        let timelineController = self.viewControllers!.first as! TimelineViewController
        
        if timelineController.date.ignoreTimeComponents() == Date().ignoreTimeComponents()
        {
            currentDateViewController = timelineController
        }
        
        dateVariable.value = timelineController.date
    }
    
    // MARK: UIPageViewControllerDataSource implementation
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        let timelineController = viewController as! TimelineViewController
        let nextDate = timelineController.date.yesterday
        
        guard viewModel.canScroll(toDate: nextDate) else { return nil }
        
        return TimelineViewController(date: nextDate,
                                      metricsService: metricsService,
                                      persistencyService: persistencyService,
                                      isEditingVariable: isEditingVariable)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        let timelineController = viewController as! TimelineViewController
        let nextDate = timelineController.date.tomorrow
        
        guard viewModel.canScroll(toDate: nextDate) else { return nil }
        
        return TimelineViewController(date: nextDate,
                                      metricsService: metricsService,
                                      persistencyService: persistencyService,
                                      isEditingVariable: isEditingVariable)
    }
}
