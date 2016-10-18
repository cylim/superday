import UIKit
import RxSwift

class OnboardingPage : UIViewController
{
    private(set) var didAppear = false
    private(set) var nextButtonText : String?
    private var onboardingPageViewController : OnboardingPageViewController!
    
    init?(coder aDecoder: NSCoder, nextButtonText: String?)
    {
        super.init(coder: aDecoder)
        
        self.nextButtonText = nextButtonText
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func inject(_ onboardingPageViewController: OnboardingPageViewController)
    {
        self.onboardingPageViewController = onboardingPageViewController
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        guard !self.didAppear else { return }
        self.didAppear = true
        
        self.startAnimations()
    }
    
    func finish()
    {
        self.onboardingPageViewController.goToNextPage()
    }
    
    func startAnimations()
    {
        // override in page
    }
    
    func appBecameActive()
    {
        // override in page
    }
    
    func t(_ hours : Int, _ minutes : Int) -> Date
    {
        return Date()
            .ignoreTimeComponents()
            .addingTimeInterval(TimeInterval((hours * 60 + minutes) * 60))
    }
}
