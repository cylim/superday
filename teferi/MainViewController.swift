import UIKit
import CoreLocation

class MainViewController : BaseViewController<MainViewModel>
{
    override func createViewModel() -> MainViewModel?
    {
        return MainViewModel(locationService: DefaultLocationService())
    }
}