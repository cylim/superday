import Foundation

struct TimelineItem
{
    let timeSlot : TimeSlot
    
    let durations : [ TimeInterval ]
    
    let lastInPastDay : Bool
    
    let shouldDisplayCategoryName : Bool
}
