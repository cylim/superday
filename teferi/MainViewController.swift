import UIKit
import CoreLocation
import RxSwift

class MainViewController : UIPageViewController
{
    private let viewModel : MainViewModel = MainViewModel(locationService: DefaultLocationService())
    private let label = UILabel()
    private let timelineViewControllers : [UIViewController] = [ TimelineViewController(), TimelineViewController(), TimelineViewController() ]
    
    private var disposeBag : DisposeBag? = DisposeBag()
    
    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : AnyObject]?) {
        super.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: options)
    }
    
    required init?(coder: NSCoder) {
        super.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        viewModel.start()
        
        dataSource = self
        
        setViewControllers(
                [timelineViewControllers.first!],
                direction: .Forward,
                animated: false,
                completion: nil)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        createBindings()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        disposeBag = nil
        super.viewWillDisappear(animated)
    }
    
    func createBindings()
    {
        viewModel
            .currentLocation
            .asObservable()
            .subscribe(onNext: onNextLocation)
            .addDisposableTo(disposeBag!)
    }
    
    private func onNextLocation(location: Location)
    {
        //label.text = "Latitude: \(location.latitude) | Longitude: \(location.longitude)"
    }
}

extension MainViewController : UIPageViewControllerDataSource
{
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        let previousIndex = timelineViewControllers.indexOf(viewController)!
        let currentIndex = (previousIndex + 1) % (timelineViewControllers.count - 1)
        return timelineViewControllers[currentIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        let nextIndex = timelineViewControllers.indexOf(viewController)!
        let currentIndex = nextIndex - 1 < 0 ? (timelineViewControllers.count - 1) : nextIndex - 1
        return timelineViewControllers[currentIndex]
    }
}




















