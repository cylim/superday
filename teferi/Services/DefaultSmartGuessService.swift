import Foundation
import CoreLocation

class DefaultSmartGuessService : SmartGuessService
{
    //MARK: Fields
    private let loggingService: LoggingService
    private let settingsService: SettingsService
    private let persistencyService : BasePersistencyService<SmartGuess>
    
    init(loggingService: LoggingService, settingsService: SettingsService, persistencyService: BasePersistencyService<SmartGuess>)
    {
        self.loggingService = loggingService
        self.settingsService = settingsService
        self.persistencyService = persistencyService
    }
    
    func add(smartGuess: SmartGuess) -> Bool
    {
        //The previous TimeSlot needs to be finished before a new one can start
        guard self.persistencyService.create(smartGuess) else
        {
            self.loggingService.log(withLogLevel: .error, message: "Failed to create new SmartGuess")
            return false
        }
        
        //Bump the identifier
        self.settingsService.incrementSmartGuessId()
        self.loggingService.log(withLogLevel: .info, message: "New SmartGuess with category \"\(smartGuess.category)\" created")
        
        return true
    }
    
    func strike(withId id: Int)
    {
        let predicate = Predicate(parameter: "id", equals: id as AnyObject)
        let editFunction = { (smartGuess: SmartGuess) -> (SmartGuess) in
            
            smartGuess.errorCount += 1
            return smartGuess
        }
        
        if !self.persistencyService.update(withPredicate: predicate, updateFunction: editFunction)
        {
            self.loggingService.log(withLogLevel: .error, message: "Error trying to increase errorCount of SmartGuess with id \(id)")
        }
    }
    
    func get(forLocation location: CLLocation) -> SmartGuess
    {
        let bestMatches = self.persistencyService.get()
            .filter(self.isWithinHundredMeters(location))
            .sorted(by: self.sortByDistance(location))
        
        //TODO: This will have to be improved in the future to use some sort of weighted system taking into account more data.
        guard let bestMatch = bestMatches.first else { return SmartGuess.empty }
        
        //Every time a dictionary entry gets used in a guess, it gets refreshed.
        //Entries not refresh in N days get purged
        bestMatch.lastUsed = Date()
        
        return bestMatch
    }
    
    func purgeEntries(olderThan days: Int)
    {
        guard let initialDate = self.settingsService.installDate,
            initialDate.differenceInDays(toDate: Date()) > days else { return }
        
        
        let predicate = Predicate(parameter: "lastUsed",
                                  rangesFromDate: initialDate as NSDate,
                                  toDate: Date().add(days: -days) as NSDate)
        
        self.persistencyService.delete(withPredicate: predicate)
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
