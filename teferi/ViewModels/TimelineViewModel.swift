import Foundation
import RxSwift

class TimelineViewModel
{
    // MARK: Properties
    let date : NSDate
    var timeSlots = Variable<[TimeSlot]>([])
    
    init(date: NSDate)
    {
        self.date = date
    }
    
    func addNewSlot(category: Category)
    {
        //Finishes last task, if needed
        if let lastTimeSlot = timeSlots.value.last
        {
            lastTimeSlot.endTime = NSDate()
        }
        
        timeSlots.value.append(TimeSlot(category: category))
    }
}