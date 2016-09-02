import Foundation

class TimelineViewModel
{
    var timeSlots = [TimeSlot]()
    
    init()
    {
        timeSlots.append(TimeSlot())
        timeSlots.append(TimeSlot())
    }
}