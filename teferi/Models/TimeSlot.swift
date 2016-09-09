import Foundation

class TimeSlot
{
    // MARK: Properties
    var category : Category = Category.Unknown
    var startTime : NSDate = NSDate()
    var endTime : NSDate? = nil
    
    var duration : NSTimeInterval
    {
        let endTime = self.endTime ?? NSDate()
        return endTime.timeIntervalSinceDate(startTime)
    }
    
    // MARK: Initializers
    convenience init(category: Category)
    {
        self.init()
        self.category = category
    }
}