import Foundation

open class TimeSlot
{
    // MARK: Properties
    var category : Category = Category.Unknown
    var startTime : Date = Date()
    var endTime : Date? = nil
    
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
    fileprivate func getEndDate() -> Date
    {
        let date = Date()
        let timeEntryLimit = startTime.addDays(1).ignoreTimeComponents()
        let timeEntryLastedOverOneDay = date.compare(timeEntryLimit) == ComparisonResult.orderedDescending
        return timeEntryLastedOverOneDay ? timeEntryLimit : date
    }
}
