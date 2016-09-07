import UIKit
import CoreLocation
import RxSwift
import CircleMenu

class MainViewController : UIPageViewController, UIPageViewControllerDataSource, CircleMenuDelegate
{
    // MARK: Fields
    private let menuItems : [Category] = [
        Category.Friends,
        Category.Work,
        Category.Leisure,
        Category.Commute,
        Category.Food
    ]
    
    private let currentDateViewController = TimelineViewController(date: NSDate())
    private let viewModel : MainViewModel = MainViewModel(locationService: DefaultLocationService())
    private var disposeBag : DisposeBag? = DisposeBag()
    private var circleMenu : CircleMenu? = nil
    
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
        
        setMenuButton()
        
        setViewControllers(
            [ currentDateViewController ],
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
    
    // MARK: Methods
    private func setMenuButton()
    {
        let buttonSize = CGFloat(50)
        
        circleMenu = CircleMenu(
            frame: CGRect(x: UIScreen.mainScreen().bounds.width / 2 - buttonSize / 2, y: UIScreen.mainScreen().bounds.height - 150, width: buttonSize, height: buttonSize),
            normalIcon:"icAddGrey",
            selectedIcon:"icCancelGrey",
            buttonsCount: 5,
            duration: 0.5,
            distance: 90)
        circleMenu!.delegate = self
        circleMenu!.layer.cornerRadius = circleMenu!.frame.size.width / 2.0
        view.addSubview(circleMenu!)
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
    
    //MARK: CircleMenuDelegate implementation
    func circleMenu(circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int)
    {
        let category = menuItems[atIndex]
        
        button.backgroundColor = category.color
        button.setImage(UIImage(imageLiteral: category.imageAssetName), forState: .Normal)
        
        // set highlited image
        let highlightedImage  = UIImage(imageLiteral: category.imageAssetName).imageWithRenderingMode(.AlwaysTemplate)
        button.setImage(highlightedImage, forState: .Highlighted)
        button.tintColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.3)
    }
    
    func circleMenu(circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int)
    {
        currentDateViewController.addNewSlot(menuItems[atIndex])
    }
    
    func circleMenu(circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int)
    {
        print("button did selected: \(atIndex)")
    }
}




















