import Nimble
import RxSwift
import XCTest
@testable import teferi

class MainViewModelTests : XCTestCase
{
    private var disposable : Disposable? = nil
    private var mockLocationService = MockLocationService()
    private var viewModel = MainViewModel(locationService: MockLocationService())
    
    override func setUp()
    {
        mockLocationService = MockLocationService()
        viewModel = MainViewModel(locationService: mockLocationService)
        viewModel.start()
    }
    
    override func tearDown()
    {
        disposable?.dispose()
    }
    
    func testStartMethodSubscribesToTheLocationService()
    {
        expect(self.mockLocationService.didSubscribe).to(equal(true))
    }
    
    func testTheCurrentLocationGetsUpdatedWhenTheLocationServiceBroadcasts()
    {
        var locationChanged = false
        disposable = self.viewModel.locationObservable.subscribe { location in locationChanged = true }
        let location = Location(latitude: 5, longitude: 5)
                        
        self.mockLocationService.setMockLocation(location)
        expect(locationChanged).to(equal(true))
    }
}