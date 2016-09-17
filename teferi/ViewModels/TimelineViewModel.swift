import Foundation
import RxSwift

class TimelineViewModel
{
    // MARK: Fields
    private let persistencyService : PersistencyService
    private let timeSlotsVariable : Variable<[TimeSlot]>
    
    // MARK: Properties
    let date : Date
    let timeObservable : Observable<Int>
    let timeSlotsObservable : Observable<[TimeSlot]>
    
    private(set) var timeSlots : [TimeSlot]
    {
        get { return timeSlotsVariable.value }
        set(value) { timeSlotsVariable.value = value }
    }
    
    // MARK: Initializers
    init(date: Date, persistencyService: PersistencyService)
    {
        let isCurrentDay = Date().ignoreTimeComponents() == date.ignoreTimeComponents()
        
        //UI gets notified once every n seconds that the last item might need to be redrawn
        self.timeObservable = isCurrentDay ? Observable<Int>.timer(0, period: 30, scheduler: MainScheduler.instance) : Observable.empty()
        self.date = date
        self.persistencyService = persistencyService
        self.timeSlotsVariable = Variable(persistencyService.getTimeSlots(forDay: date))
        self.timeSlotsObservable = timeSlotsVariable.asObservable()
        
        
        //Only the current day subscribes for new TimeSlots
        guard isCurrentDay else { return }
        
        persistencyService.subscribeToTimeSlotChanges(onNewTimeSlot)
    }
    
    // MARK: Methods
    func addNewSlot(withCategory category: Category)
    {
        let newSlot = TimeSlot(category: category)
        
        guard persistencyService.addNewTimeSlot(newSlot) else
        {
            //TODO: Recover if saving fails
            return
        }
    }
    
    private func onNewTimeSlot(timeSlot: TimeSlot)
    {
        //Finishes last task, if needed
        if let lastTimeSlot = timeSlots.last
        {
            lastTimeSlot.endTime = Date()
        }
        
        timeSlots.append(timeSlot)
    }
}
