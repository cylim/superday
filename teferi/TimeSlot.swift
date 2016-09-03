import Foundation

class TimeSlot
{
    var category : Category = Category.Unknown
    var startTime : NSDate = NSDate()
    var endTime : NSDate? = nil
    
    var duration : NSTimeInterval
    {
        let endTime = self.endTime ?? NSDate()
        return endTime.timeIntervalSinceDate(startTime)
    }
}