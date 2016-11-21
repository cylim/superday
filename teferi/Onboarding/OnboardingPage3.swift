import UIKit
import RxSwift
import CoreLocation

class OnboardingPage3 : OnboardingPage, CLLocationManagerDelegate
{
    private var locationManager: CLLocationManager!
    private var disposeBag : DisposeBag? = DisposeBag()
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder, nextButtonText: nil)
    }
    
    override func startAnimations()
    {
        self.disposeBag = self.disposeBag ?? DisposeBag()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        
        self.appStateService
            .appStateObservable
            .subscribe(onNext: self.onAppStateChanged)
            .addDisposableTo(self.disposeBag!)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if status == .authorizedAlways || status == .denied
        {
            if status == .authorizedAlways
            {
                self.settingsService.setAllowedLocationPermission()
            }
            
            self.finish()
        }
    }
    
    override func finish()
    {
        super.finish()
        disposeBag = nil
    }
    
    func onAppStateChanged(appState: AppState)
    {
        if appState == .active
            && self.onboardingPageViewController.isCurrent(page: self)
            && !self.settingsService.hasLocationPermission
        {
            self.locationManager.requestAlwaysAuthorization()
        }
    }
}
