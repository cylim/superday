import XCTest
import RxSwift
@testable import teferi

class MainViewModelTests : XCTestCase
{
    private var mockLocationService = MockLocationService()
    private var viewModel = MainViewModel(locationService: MockLocationService())
    
    override func setUp()
    {
        super.setUp()
        mockLocationService = MockLocationService()
        viewModel = MainViewModel(locationService: mockLocationService)
    }
    
    func theStartMethodSubscribeToTheLocationService()
    {
        viewModel.start()
        XCTAssertTrue(mockLocationService.didSubscribe)
    }
    
    func theLocationObservableIsUpdatedWhenTheServiceBroadcastsNewLocations()
    {
        viewModel.start()
        
        var locationChanged = false
        let disposable = viewModel.currentLocation.asObservable().subscribe { location in locationChanged = true }
        let location = Location(latitude: 5, longitude: 5)
        
        mockLocationService.setMockLocation(location)
        
        XCTAssertTrue(locationChanged)
        
        disposable.dispose()
    }
}
