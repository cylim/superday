import Foundation
import CoreData
import CoreLocation

/// Represents each individual activity performed by the app user.
class TimeSlot
{
    // MARK: Properties
    let startTime : Date
    let wasSmartGuessed : Bool
    let location : CLLocation?
    
    var endTime : Date? = nil
    var category = Category.unknown
    
    ///Calculates and returns the total duration for the TimeSlot.
    var duration : TimeInterval
    {
        let endTime = self.endTime ?? self.getEndTime()
        return endTime.timeIntervalSince(self.startTime)
    }
    
    // MARK: Initializers
    init()
    {
        self.location = nil
        self.startTime = Date()
        self.wasSmartGuessed = false
    }
    
    init(withStartTime time: Date)
    {
        self.location = nil
        self.startTime = time
        self.wasSmartGuessed = false
    }
    
    init(withLocation location: CLLocation, smartGuessedCategory: Category)
    {
        self.location = location
        self.wasSmartGuessed = true
        self.startTime = location.timestamp
        self.category = smartGuessedCategory
    }
    
    init(withStartTime startTime: Date, endTime: Date?, category: Category, location: CLLocation, wasSmartGuessed: Bool)
    {
        self.endTime = endTime
        self.category = category
        self.location = location
        self.startTime = startTime
        self.wasSmartGuessed = wasSmartGuessed
    }
    
    convenience init(withStartTime startTime: Date, endTime: Date?, category: Category)
    {
        self.init(withStartTime: startTime)
        self.endTime = endTime
        self.category = category
    }
    
    convenience init(withCategory category: Category)
    {
        self.init()
        self.category = category
    }
    
    // MARK: Methods
    private func getEndTime() -> Date
    {
        let date = Date()
        let timeEntryLimit = self.startTime.tomorrow.ignoreTimeComponents()
        let timeEntryLastedOverOneDay = date.compare(timeEntryLimit) == ComparisonResult.orderedDescending
    
        //The `endTime` property can never exceed midnight of the TimeSlot day, so this property considers it before returning the proper TimeInterval
        return timeEntryLastedOverOneDay ? timeEntryLimit : date
    }
}
