import UIKit

class OnboardingPage4 : OnboardingPage
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder, nextButtonText: nil)
    }
    
    override func startAnimations()
    {
        self.subscribeToAppActiveStatus()
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
    }
    
    override func appBecameActive()
    {
        self.finish()
    }
}
