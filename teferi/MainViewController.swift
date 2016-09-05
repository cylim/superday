import UIKit
import CoreLocation
import RxSwift

class MainViewController : UIPageViewController, UIPageViewControllerDataSource
{
    // MARK: Fields
    private let viewModel : MainViewModel = MainViewModel(locationService: DefaultLocationService())
    private var disposeBag : DisposeBag? = DisposeBag()
    
    // MARK: Initializers
    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : AnyObject]?)
    {
        super.init(transitionStyle: .Scroll,
                   navigationOrientation: .Horizontal,
                   options: options)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(transitionStyle: .Scroll,
                   navigationOrientation: .Horizontal,
                   options: nil)
    }
    
    // MARK: UIViewController lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        viewModel.start()
        
        view.backgroundColor = UIColor.whiteColor()
        dataSource = self
        
        setViewControllers(
            [TimelineViewController(date: NSDate())],
            direction: .Forward,
            animated: false,
            completion: nil)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        viewModel
            .currentLocation
            .asObservable()
            .subscribe(onNext: onNextLocation)
            .addDisposableTo(disposeBag!)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        disposeBag = nil
        super.viewWillDisappear(animated)
    }
    
    // MARK: RxSwift callbacks
    private func onNextLocation(location: Location)
    {
        //TODO: Add logic for location changes
    }
    
    // MARK: UIPageViewControllerDataSource implementation
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        let timelineController = viewController as! TimelineViewController
        let currentDate = timelineController.date
        let nextDate = currentDate.addDays(-1)
        return TimelineViewController(date: nextDate)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        let timelineController = viewController as! TimelineViewController
        let currentDate = timelineController.date
        let canScrollOn = !currentDate.equalsDate(NSDate())
        if canScrollOn
        {
            let nextDate = currentDate.addDays(1)
            return TimelineViewController(date: nextDate)
        }
        else
        {
            return nil
        }
    }
}




















