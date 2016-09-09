import UIKit

class PagerViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
    // MARK: Fields
    private let currentDateViewController = TimelineViewController(date: NSDate())
    
    // MARK: Properties
    var onDateChanged : (NSDate -> Void)? = nil
    
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
        
        view.backgroundColor = UIColor.whiteColor()
        delegate = self
        dataSource = self
        
        setViewControllers(
            [ currentDateViewController ],
            direction: .Forward,
            animated: false,
            completion: nil)
    }
    
    // MARK: Methods
    func addNewSlot(category: Category)
    {
        currentDateViewController.addNewSlot(category)
    }
    
    // MARK: UIPageViewControllerDelegate implementation
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        guard completed else { return }
        
        let timelineController = self.viewControllers!.first as! TimelineViewController
        onDateChanged?(timelineController.date)
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