import Foundation

public class TimeSlot
{
    // MARK: Properties
    var category : Category = Category.Unknown
    var startTime : NSDate = NSDate()
    var endTime : NSDate? = nil
    
    var duration : NSTimeInterval
    {
        let endTime = self.endTime ?? getEndDate()
        return endTime.timeIntervalSinceDate(startTime)
    }
    
    // MARK: Initializers
    convenience init(category: Category)
    {
        self.init()
        self.category = category
    }
    
    // MARK: Methods
    private func getEndDate() -> NSDate
    {
        let date = NSDate()
        let timeEntryLimit = startTime.addDays(1).ignoreTimeComponents()
        let timeEntryLastedOverOneDay = date.compare(timeEntryLimit) == NSComparisonResult.OrderedDescending
        return timeEntryLastedOverOneDay ? timeEntryLimit : date
    }
}