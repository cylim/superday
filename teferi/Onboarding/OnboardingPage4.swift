import UIKit
import RxSwift

class OnboardingPage4 : OnboardingPage
{
    private var appActiveSubscription : Disposable?
    private var notificationAuthorizationObservable : Observable<Bool>!
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder, nextButtonText: nil)
    }
    
    func inject(_ onboardingPageViewController: OnboardingPageViewController, _ notificationAuthorizationObservable: Observable<Bool>)
    {
        super.inject(onboardingPageViewController)
        
        self.notificationAuthorizationObservable = notificationAuthorizationObservable
    }
    
    override func startAnimations()
    {
        self.appActiveSubscription =
            self.notificationAuthorizationObservable
                .subscribe(onNext: { wasSet in
                    
                    guard wasSet else { return }
                    
                    self.appActiveSubscription?.dispose()
                    self.finish()
                })
        
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge ], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
    }
}
