import Foundation
import CoreLocation

class DefaultSmartGuessService : SmartGuessService
{
    //MARK: Fields
    private let smartGuessErrorThreshold = 3
    private let smartGuessIdKey = "smartGuessId"
    private let timeService : TimeService
    private let loggingService: LoggingService
    private let settingsService: SettingsService
    private let persistencyService : BasePersistencyService<SmartGuess>
    
    init(timeService: TimeService,
         loggingService: LoggingService,
         settingsService: SettingsService,
         persistencyService: BasePersistencyService<SmartGuess>)
    {
        self.timeService = timeService
        self.loggingService = loggingService
        self.settingsService = settingsService
        self.persistencyService = persistencyService
    }
    
    @discardableResult func add(withCategory category: Category, location: CLLocation) -> SmartGuess?
    {
        let id = self.getNextSmartGuessId()
        let smartGuess = SmartGuess(withId: id, category: category, location: location, lastUsed: self.timeService.now)
        
        guard self.persistencyService.create(smartGuess) else
        {
            self.loggingService.log(withLogLevel: .error, message: "Failed to create new SmartGuess")
            return nil
        }
        
        //Bump the identifier
        self.incrementSmartGuessId()
        self.loggingService.log(withLogLevel: .info, message: "New SmartGuess with category \"\(smartGuess.category)\" created")
        
        return smartGuess
    }
    
    func strike(withId id: Int)
    {
        let predicate = Predicate(parameter: SmartGuessModelAdapter.idKey, equals: id as AnyObject)
        
        // Invalid Ids should be ignore
        guard let smartGuess = self.persistencyService.get(withPredicate: predicate).first else
        {
            self.loggingService.log(withLogLevel: .warning, message: "Tried striking smart guess with invalid id \(id)")
            return
        }
        
        // Purge SmartGuess if needed
        if self.shouldPurge(smartGuess: smartGuess)
        {
            self.persistencyService.delete(withPredicate: predicate)
            return
        }
        
        let editFunction = { (smartGuess: SmartGuess) -> (SmartGuess) in
            
            smartGuess.errorCount += 1
            return smartGuess
        }
        
        if !self.persistencyService.update(withPredicate: predicate, updateFunction: editFunction)
        {
            self.loggingService.log(withLogLevel: .warning, message: "Error trying to increase errorCount of SmartGuess with id \(id)")
        }
    }
    
    func get(forLocation location: CLLocation) -> SmartGuess?
    {
        let bestMatches = self.persistencyService.get()
            .filter(self.isWithinHundredMeters(location))
            .sorted(by: self.sortByDistance(location))
        
        //TODO: This will have to be improved in the future to use some sort of weighted system taking into account more data.
        guard let bestMatch = bestMatches.first else { return nil }
        
        //Every time a dictionary entry gets used in a guess, it gets refreshed.
        //Entries not refresh in N days get purged
        let lastUsedDate = self.timeService.now
        
        let predicate = Predicate(parameter: SmartGuessModelAdapter.idKey, equals: bestMatch.id as AnyObject)
        self.persistencyService.update(withPredicate: predicate, updateFunction: { smartGuess in
            smartGuess.lastUsed = lastUsedDate
            return smartGuess
        })
        
        bestMatch.lastUsed = lastUsedDate
        
        return bestMatch
    }
    
    func purgeEntries(olderThan maxAge: Date)
    {
        guard let initialDate = self.settingsService.installDate, maxAge > initialDate else { return }
        
        let predicate = Predicate(parameter: "lastUsed",
                                  rangesFromDate: initialDate as NSDate,
                                  toDate: maxAge as NSDate)
        
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
    
    private func getNextSmartGuessId() -> Int
    {
        return UserDefaults.standard.integer(forKey: self.smartGuessIdKey)
    }
    
    private func incrementSmartGuessId()
    {
        var id = self.getNextSmartGuessId()
        id += 1
        UserDefaults.standard.set(id, forKey: self.smartGuessIdKey)
    }
    
    private func shouldPurge(smartGuess: SmartGuess) -> Bool
    {
        return smartGuess.errorCount >= smartGuessErrorThreshold
    }
}
