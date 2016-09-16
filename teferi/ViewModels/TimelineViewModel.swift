import Foundation
import RxSwift

class TimelineViewModel
{
    // MARK: Fields
    fileprivate let persistencyService : PersistencyService
    fileprivate let timeSlotsVariable : Variable<[TimeSlot]>
    
    // MARK: Properties
    let date : Date
    let timeSlotsObservable : Observable<[TimeSlot]>
    
    fileprivate(set) var timeSlots : [TimeSlot]
    {
        get { return timeSlotsVariable.value }
        set(value) { timeSlotsVariable.value = value }
    }
    
    // MARK: Initializers
    init(date: Date, persistencyService: PersistencyService)
    {
        self.date = date
        self.persistencyService = persistencyService
        self.timeSlotsVariable = Variable(persistencyService.getTimeSlotsForDay(date))
        self.timeSlotsObservable = timeSlotsVariable.asObservable()
    }
    
    // MARK: Methods
    func addNewSlot(_ category: Category)
    {
        let newSlot = TimeSlot(category: category)
        
        //TODO: Recover if saving fails
        guard persistencyService.addNewTimeSlot(newSlot) else { return }
        
        //Finishes last task, if needed
        if let lastTimeSlot = timeSlots.last
        {
            lastTimeSlot.endTime = Date()
        }
        
        timeSlots.append(newSlot)
    }
}
