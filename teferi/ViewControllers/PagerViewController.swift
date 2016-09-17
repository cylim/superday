import UIKit

class PagerViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
    // MARK: Fields
    fileprivate var currentDateViewController = TimelineViewController(date: Date())
    
    // MARK: Properties
    var onDateChanged : ((Date) -> Void)? = nil
    
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
        
        setViewControllers(
            [ currentDateViewController ],
            direction: .forward,
            animated: false,
            completion: nil)
    }
    
    // MARK: Methods
    func addNewSlot(withCategory category: Category)
    {
        currentDateViewController.addNewSlot(withCategory: category)
    }
    
    // MARK: UIPageViewControllerDelegate implementation
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        guard completed else { return }
        
        let timelineController = self.viewControllers!.first as! TimelineViewController
        onDateChanged?(timelineController.date as Date)
    }
    
    // MARK: UIPageViewControllerDataSource implementation
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        let timelineController = viewController as! TimelineViewController
        let currentDate = timelineController.date
        let nextDate = currentDate.yesterday
        return TimelineViewController(date: nextDate)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        let timelineController = viewController as! TimelineViewController
        let currentDate = timelineController.date.ignoreTimeComponents()
        let canScrollOn = currentDate != Date().ignoreTimeComponents()
        if canScrollOn
        {
            let nextDate = currentDate.tomorrow
            let newController = TimelineViewController(date: nextDate)
            if nextDate.ignoreTimeComponents() == Date().ignoreTimeComponents()
            {
                currentDateViewController = newController
            }
            
            return newController
        }
        else
        {
            return nil
        }
    }
}
