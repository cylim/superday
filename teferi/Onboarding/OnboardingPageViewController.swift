import UIKit

class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDataSource
{
    private lazy var pages: [UIViewController] =
    {
        return (1...4).map({i in self.page("\(i)")})
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        dataSource = self
        
        setViewControllers([pages.first!],
                           direction: .forward,
                           animated: true,
                           completion: nil)
        
        view.backgroundColor = UIColor.white
    }
    
    // MARK: UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        guard let currentPageIndex = pages.index(of: viewController) else
        {
            return nil
        }
        
        return pageAt(index: currentPageIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let currentPageIndex = pages.index(of: viewController) else
        {
            return nil
        }
        
        return pageAt(index: currentPageIndex + 1)
    }
    
    func pageAt(index : Int) -> UIViewController?
    {
        guard 0..<pages.count ~= index else
        {
            return nil
        }
        
        return pages[index]
    }
    
    private func page(_ id: String) -> UIViewController
    {
        return UIStoryboard(name: "Onboarding", bundle: nil)
            .instantiateViewController(withIdentifier: "OnboardingScreen\(id)")
    }

}

