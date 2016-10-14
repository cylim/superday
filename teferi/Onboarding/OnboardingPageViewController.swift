import UIKit
import SnapKit

class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDataSource
{
    private lazy var pages : [UIViewController] = { return (1...4).map { i in self.page("\(i)") } } ()
    
    @IBOutlet var pager: OnboardingPager!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.dataSource = self
        self.view.backgroundColor = UIColor.white
        self.setViewControllers([pages.first!],
                           direction: .forward,
                           animated: true,
                           completion: nil)
        
        let pageControl = UIPageControl.appearance(whenContainedInInstancesOf: [type(of: self)])
        
        pageControl.currentPageIndicatorTintColor = UIColor.green
        pageControl.pageIndicatorTintColor = UIColor.green.withAlphaComponent(0.4)
        pageControl.backgroundColor = UIColor.clear
        
        self.view.addSubview(self.pager)
        self.pager.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.height.equalTo(102)
        }
    }
    
    @IBAction func pagerButtonTouchUpInside()
    {
        self.goToNextPage()
    }
    
    private func goToNextPage()
    {
        let currentPageIndex = pages.index(of: self.viewControllers!.first!)!
        guard let nextPage = self.pageAt(index: currentPageIndex + 1) else { return }
        
        self.setViewControllers([nextPage],
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
