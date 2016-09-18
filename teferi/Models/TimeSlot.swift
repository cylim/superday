import Foundation

/// Represents each individual activity performed by the app user.
class TimeSlot
{
    // MARK: Properties
    var startTime : Date = Date()
    var endTime : Date? = nil
    var category : Category = Category.Unknown
    
    ///Calculates and returns the total duration for the TimeSlot.
    var duration : TimeInterval
    {
        let endTime = self.endTime ?? getEndDate()
        return endTime.timeIntervalSince(startTime)
    }
    
    // MARK: Initializers
    convenience init(category: Category)
    {
        self.init()
        self.category = category
    }
    
    // MARK: Methods
    private func getEndDate() -> Date
    {
        let date = Date()
        let timeEntryLimit = startTime.tomorrow.ignoreTimeComponents()
        let timeEntryLastedOverOneDay = date.compare(timeEntryLimit) == ComparisonResult.orderedDescending
    
        //The `endTime` property can never exceed midnight of the TimeSlot day, so this property considers it before returning the proper TimeInterval
        return timeEntryLastedOverOneDay ? timeEntryLimit : date
    }
}
