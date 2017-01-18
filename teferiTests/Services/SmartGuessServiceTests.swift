@testable import teferi
import XCTest
import Foundation
import CoreLocation
import Nimble

class SmartGuessServiceTests : XCTestCase
{
    private var timeService : MockTimeService!
    private var loggingService : MockLoggingService!
    private var settingsService : MockSettingsService!
    private var persistencyService : MockSmartGuessPersistencyService!
    
    private var smartGuessService : DefaultSmartGuessService!
    
    override func setUp()
    {
        self.timeService = MockTimeService()
        self.loggingService = MockLoggingService()
        self.settingsService = MockSettingsService()
        self.persistencyService = MockSmartGuessPersistencyService()
        
        
        self.smartGuessService = DefaultSmartGuessService(timeService: self.timeService,
                                                          loggingService: self.loggingService,
                                                          settingsService: self.settingsService,
                                                          persistencyService: self.persistencyService)
    }
    
    func testGuessesVeryCloseToTheLocationShouldOutweighMultipleGuessesSlightlyFurtherAway()
    {
        self.persistencyService.smartGuesses =
            [  ( 41.9752219072946, -71.0224522245947, teferi.Category.work ),
               ( 41.9753319073047, -71.0223522246947, teferi.Category.work ),
               ( 41.9753219072949, -71.0224522245947, teferi.Category.work ),
               ( 41.9754219072948, -71.0229522245947, teferi.Category.leisure ),
               ( 41.9754219072950, -71.0222522245947, teferi.Category.work ),
               ( 41.9757219072951, -71.0225522245947, teferi.Category.leisure ) ]
                .map(toLocation)
                .map(toSmartGuess)
        
        let targetLocation = CLLocation(latitude: 41.9754219072948, longitude: -71.0230522245947)
        
        let smartGuess = self.smartGuessService.get(forLocation: targetLocation)!
        
        expect(smartGuess.category).to(equal(teferi.Category.leisure))
    }
    
    func testGuessesVeryCloseToTheLocationShouldOutweighMultipleGuessesSlightlyFurtherAwayEvenWithoutExtraGuessesHelpingTheWeight()
    {
        self.persistencyService.smartGuesses =
            [  ( 41.9752219072946, -71.0224522245947, teferi.Category.work ),
               ( 41.9753319073047, -71.0223522246947, teferi.Category.work ),
               ( 41.9753219072949, -71.0224522245947, teferi.Category.work ),
               ( 41.9754219072948, -71.0229522245947, teferi.Category.leisure ),
               ( 41.9754219072950, -71.0222522245947, teferi.Category.work ) ]
                .map(toLocation)
                .map(toSmartGuess)
        
        let targetLocation = CLLocation(latitude: 41.9754219072948, longitude: -71.0230522245947)
        
        let smartGuess = self.smartGuessService.get(forLocation: targetLocation)!
        
        expect(smartGuess.category).to(equal(teferi.Category.leisure))
    }
    
    func testTheAmountOfGuessesInTheSameCategoryShouldMatterWhenComparingSimilarlyDistantGuessesEvenIfTheOutnumberedGuessIsCloser()
    {
        self.persistencyService.smartGuesses =
            [  ( 41.9752219072946, -71.0224522245947, teferi.Category.work ),
               ( 41.9753319073047, -71.0223522246947, teferi.Category.work ),
               ( 41.9753219072949, -71.0224522245947, teferi.Category.work ),
               ( 41.9754219072950, -71.0222522245947, teferi.Category.work ),
               ( 41.9757219072951, -71.0225522245947, teferi.Category.leisure ) ]
                .map(toLocation)
                .map(toSmartGuess)
        
        let targetLocation = CLLocation(latitude: 41.9754219072948, longitude: -71.0230522245947)
        
        let smartGuess = self.smartGuessService.get(forLocation: targetLocation)!
        
        expect(smartGuess.category).to(equal(teferi.Category.work))
    }
    
    func testTheAmountOfGuessesInTheSameCategoryShouldMatterWhenComparingSimilarlyDistantGuesses()
    {
        self.persistencyService.smartGuesses =
            [  ( 41.9752219072946, -71.0224522245947, teferi.Category.work ),
               ( 41.9753319073047, -71.0223522246947, teferi.Category.work ),
               ( 41.9753219072949, -71.0224522245947, teferi.Category.work ),
               ( 41.9754219072948, -71.0229522245947, teferi.Category.leisure ),
               ( 41.9754219072950, -71.0222522245947, teferi.Category.work ),
               ( 41.9754219072948, -71.0230522245947, teferi.Category.leisure ) ]
                .map(toLocation)
                .map(toSmartGuess)
        
        let targetLocation = CLLocation(latitude: 41.9757219072951, longitude: -71.0225522245947)
        
        let smartGuess = self.smartGuessService.get(forLocation: targetLocation)!
        
        expect(smartGuess.category).to(equal(teferi.Category.work))
    }
    
    private func toLocation(latLngCategory: (Double, Double, teferi.Category)) -> (CLLocation, teferi.Category)
    {
        return (CLLocation(latitude: latLngCategory.0, longitude: latLngCategory.1), latLngCategory.2)
    }
    
    private func toSmartGuess(locationAndCategory: (CLLocation, teferi.Category)) -> SmartGuess
    {
        return SmartGuess(withId: 0, category: locationAndCategory.1, location: locationAndCategory.0, lastUsed: Date())
    }
}
