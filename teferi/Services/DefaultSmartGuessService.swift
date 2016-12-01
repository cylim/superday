import Foundation
import CoreLocation

class DefaultSmartGuessService : SmartGuessService
{
    //MARK: Fields
    private let persistencyService : BasePersistencyService<SmartGuess>
    
    init(persistencyService: BasePersistencyService<SmartGuess>)
    {
        self.persistencyService = persistencyService
    }
    
    func getCategory(forLocation location: CLLocation) -> Category
    {
        let bestMatches = self.persistencyService.get()
            .filter(self.isWithinHundredMeters(location))
            .sorted(by: self.sortByDistance(location))
        
        //TODO: This will have to be improved in the future to use some sort of weighted system taking into account more data.
        guard let bestMatch = bestMatches.first else { return .unknown }
        
        //Every time a dictionary entry gets used in a guess, it gets refreshed.
        //Entries not refresh in N days get purged
        bestMatch.lastUsed = Date()
        return bestMatch.category
    }
    
    private func isWithinHundredMeters(_ location: CLLocation) -> (SmartGuess) -> Bool
    {
        //TODO: We have to think about the 100m constant. Might be (significantly?) too low.
        return { smartGuess in return smartGuess.location.distance(from: location) <= 100 }
    }
    
    private func sortByDistance(_ location: CLLocation) -> (SmartGuess, SmartGuess) -> Bool
    {
        return { (smartGuess1, smartGuess2) in smartGuess1.location.distance(from: location) > smartGuess2.location.distance(from: location) }
    }
}
