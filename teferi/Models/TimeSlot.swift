import Foundation
import CoreData
import CoreLocation

/// Represents each individual activity performed by the app user.
class TimeSlot
{
    // MARK: Properties
    let startTime : Date
    let location : CLLocation?
    
    var endTime : Date? = nil
    var category = Category.unknown
    var categoryWasSetByUser : Bool
    
    ///Calculates and returns the total duration for the TimeSlot.
    var duration : TimeInterval
    {
        let endTime = self.endTime ?? self.getEndTime()
        return endTime.timeIntervalSince(self.startTime)
    }
    
    // MARK: Initializers
    init(withStartTime time: Date, categoryWasSetByUser: Bool)
    {
        self.location = nil
        self.startTime = time
        self.categoryWasSetByUser = categoryWasSetByUser
    }
    
    init(withLocation location: CLLocation, category: Category)
    {
        self.location = location
        self.category = category
        self.categoryWasSetByUser = false
        self.startTime = location.timestamp
    }
    
    init(withStartTime startTime: Date, endTime: Date?, category: Category, location: CLLocation?, categoryWasSetByUser: Bool)
    {
        self.endTime = endTime
        self.category = category
        self.location = location
        self.startTime = startTime
        self.categoryWasSetByUser = categoryWasSetByUser
    }
    
    convenience init(withStartTime time: Date)
    {
        self.init(withStartTime: time, categoryWasSetByUser: false)
    }
    
    convenience init(withStartTime startTime: Date, endTime: Date?, category: Category)
    {
        self.init(withStartTime: startTime, categoryWasSetByUser: false)
        self.endTime = endTime
        self.category = category
    }
    
    convenience init(withCategory category: Category)
    {
        self.init(withStartTime: Date(), categoryWasSetByUser: false)
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
