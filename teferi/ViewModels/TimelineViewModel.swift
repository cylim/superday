import Foundation
import RxSwift

class TimelineViewModel
{
    // MARK: Fields
    private let timeSlotsVariable = Variable<[TimeSlot]>([])
    
    // MARK: Properties
    let date : NSDate
    let timeSlotsObservable : Observable<[TimeSlot]>
    
    private(set) var timeSlots : [TimeSlot]
    {
        get { return timeSlotsVariable.value }
        set(value) { timeSlotsVariable.value = value }
    }
    
    // MARK: Initializers
    init(date: NSDate)
    {
        self.date = date
        self.timeSlotsObservable = timeSlotsVariable.asObservable()
    }
    
    // MARK: Methods
    func addNewSlot(category: Category)
    {
        //Finishes last task, if needed
        if let lastTimeSlot = timeSlots.last
        {
            lastTimeSlot.endTime = NSDate()
        }
        
        timeSlots.append(TimeSlot(category: category))
    }
}