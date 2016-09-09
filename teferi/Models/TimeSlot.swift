import Foundation

class TimeSlot
{
    var category : Category = Category.Unknown
    var startTime : NSDate = NSDate()
    var endTime : NSDate? = nil
    
    convenience init(category: Category)
    {
        self.init()
        self.category = category
    }
    
    var duration : NSTimeInterval
    {
        let endTime = self.endTime ?? NSDate()
        return endTime.timeIntervalSinceDate(startTime)
    }
}