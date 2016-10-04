import UIKit
import RxSwift

class PagerViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
    // MARK: Fields
    private let dateVariable = Variable(Date())
    private let viewModel = PagerViewModel(settingsService: AppDelegate.instance.settingsService)
    private let disposeBag = DisposeBag()
    private lazy var currentDateViewController : TimelineViewController =
    {
        return TimelineViewController(date: Date())
    }()
    
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
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        delegate = self
        dataSource = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate
            .isEditingObservable
            .subscribe(onNext: onEditChanged)
            .addDisposableTo(disposeBag)
        
        setViewControllers(
            [ currentDateViewController ],
            direction: .forward,
            animated: false,
            completion: nil)
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
        dateVariable.value = timelineController.date
    }
    
    // MARK: UIPageViewControllerDataSource implementation
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        let timelineController = viewController as! TimelineViewController
        let nextDate = timelineController.date.yesterday
        
        guard viewModel.canScroll(toDate: nextDate) else { return nil }
        
        return TimelineViewController(date: nextDate)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        let timelineController = viewController as! TimelineViewController
        let nextDate = timelineController.date.tomorrow
        
        guard viewModel.canScroll(toDate: nextDate) else { return nil }
        
        let newController = TimelineViewController(date: nextDate)
        if nextDate.ignoreTimeComponents() == Date().ignoreTimeComponents()
        {
            currentDateViewController = newController
        }
        
        return newController
    }
}
