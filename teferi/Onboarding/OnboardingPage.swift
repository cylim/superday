import UIKit
import RxSwift

class OnboardingPage: UIViewController
{
    private(set) var didAppear = false
    private(set) var nextButtonText : String?
    private var onboardingPageViewController : OnboardingPageViewController!
    private(set) var appDelegate : AppDelegate!
    
    private var appActiveSubscription : Disposable?
    
    init?(coder aDecoder: NSCoder, nextButtonText: String?)
    {
        super.init(coder: aDecoder)
        
        self.nextButtonText = nextButtonText
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func inject(_ onboardingPageViewController: OnboardingPageViewController, _ appDelegate: AppDelegate)
    {
        self.onboardingPageViewController = onboardingPageViewController
        self.appDelegate = appDelegate
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
    
    func subscribeToAppActiveStatus()
    {
        self.appActiveSubscription = self.appDelegate.appActivated
            .asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: { (active) in
                if active
                {
                    self.appBecameActive()
                    self.appActiveSubscription?.dispose()
                }
            })
    }
    
    func startAnimations()
    {
        // override in page
    }
    
    func appBecameActive()
    {
        // override in page
    }
}
