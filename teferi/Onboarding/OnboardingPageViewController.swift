import UIKit

class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDataSource
{
    private lazy var pages : [UIViewController] = { return (1...4).map { i in self.page("\(i)") } } ()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.dataSource = self
        self.view.backgroundColor = UIColor.white
        self.setViewControllers([pages.first!],
                           direction: .forward,
                           animated: true,
                           completion: nil)
    }
    
    // MARK: UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        guard let currentPageIndex = pages.index(of: viewController) else { return nil }
        
        return self.pageAt(index: currentPageIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let currentPageIndex = pages.index(of: viewController) else { return nil }
        
        return self.pageAt(index: currentPageIndex + 1)
    }
    
    private func pageAt(index : Int) -> UIViewController?
    {
        return 0..<self.pages.count ~= index ? self.pages[index] : nil
    }
    
    private func page(_ id: String) -> UIViewController
    {
        return UIStoryboard(name: "Onboarding", bundle: nil)
            .instantiateViewController(withIdentifier: "OnboardingScreen\(id)")
    }
}
