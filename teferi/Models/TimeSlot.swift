import Foundation
import CoreData

/// Represents each individual activity performed by the app user.
class TimeSlot : BaseModel
{
    // MARK: Properties
    var startTime = Date()
    var endTime : Date? = nil
    var category = Category.unknown
    
    ///Calculates and returns the total duration for the TimeSlot.
    var duration : TimeInterval
    {
        let endTime = self.endTime ?? getEndDate()
        return endTime.timeIntervalSince(startTime)
    }
    
    // MARK: Initializers
    required init() { }
    
    init(category: Category, startTime: Date, endTime: Date)
    {
        self.category = category
        self.startTime = startTime
        self.endTime = endTime
    }
    
    convenience init(category: Category)
    {
        self.init()
        self.category = category
    }
    
    convenience init(withStartDate date: Date)
    {
        self.init()
        self.startTime = date
    }
    
    // MARK: Methods
    private func getEndDate() -> Date
    {
        let date = Date()
        let timeEntryLimit = self.startTime.tomorrow.ignoreTimeComponents()
        let timeEntryLastedOverOneDay = date.compare(timeEntryLimit) == ComparisonResult.orderedDescending
    
        //The `endTime` property can never exceed midnight of the TimeSlot day, so this property considers it before returning the proper TimeInterval
        return timeEntryLastedOverOneDay ? timeEntryLimit : date
    }
}
