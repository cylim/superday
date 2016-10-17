import UIKit
import CoreLocation

class OnboardingPage3 : OnboardingPage
{
    var locationManager: CLLocationManager!
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder, nextButtonText: nil)
    }
    
    override func startAnimations()
    {
        self.subscribeToAppActiveStatus()
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
    }
    
    override func appBecameActive()
    {
        self.finish()
    }
}
