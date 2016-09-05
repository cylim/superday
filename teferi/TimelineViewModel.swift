import Foundation

class TimelineViewModel
{
    let date : NSDate
    var timeSlots = [TimeSlot]()
    
    init(date: NSDate)
    {
        self.date = date
        timeSlots.append(TimeSlot())
        timeSlots.append(TimeSlot())
    }
}