import UIKit
import CoreLocation
import RxSwift

class MainViewController : UIViewController
{
    private let viewModel : MainViewModel = MainViewModel(locationService: DefaultLocationService())
    private let label = UILabel()
    
    private var disposeBag : DisposeBag? = DisposeBag()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        viewModel.start()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        createBindings()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        disposeBag = nil
        super.viewWillDisappear(animated)
    }
    
    func createBindings()
    {
        label.frame = CGRect(x: 0, y: 0, width: 500, height: 100)
        view.addSubview(label)
        
        viewModel
            .currentLocation
            .asObservable()
            .subscribe(onNext: onNextLocation)
            .addDisposableTo(disposeBag!)
    }
    
    private func onNextLocation(location: Location)
    {
        label.text = "Latitude: \(location.latitude) | Longitude: \(location.longitude)"
    }
}