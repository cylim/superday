import Foundation
import RxSwift

///ViewModel for the TimelineViewController.
class TimelineViewModel
{
    //MARK: Fields
    private let persistencyService : PersistencyService
    private let metricsService : MetricsService
    private let timeSlotsVariable : Variable<[TimeSlot]>
    private let isEditingVariable = Variable(false)
    
    //MARK: Properties
    let date : Date
    let timeObservable : Observable<Int>
    let timeSlotsObservable : Observable<[TimeSlot]>
    let isEditingObservable : Observable<Bool>
    
    var isEditing : Bool
    {
        get { return isEditingVariable.value }
        set(value) { isEditingVariable.value = value }
    }
    
    private(set) var timeSlots : [TimeSlot]
    {
        get { return timeSlotsVariable.value }
        set(value) { timeSlotsVariable.value = value }
    }
    
    //MARK: Initializers
    init(date: Date, persistencyService: PersistencyService, metricsService : MetricsService)
    {
        let isCurrentDay = Date().ignoreTimeComponents() == date.ignoreTimeComponents()
        let timeSlotsForDate = persistencyService.getTimeSlots(forDay: date)
        
        //UI gets notified once every n seconds that the last item might need to be redrawn
        self.timeObservable = isCurrentDay ? Observable<Int>.timer(0, period: 10, scheduler: MainScheduler.instance) : Observable.empty()
        
        self.date = date
        self.persistencyService = persistencyService
        self.metricsService = metricsService
        self.timeSlotsVariable = Variable(timeSlotsForDate)
        self.isEditingObservable = isEditingVariable.asObservable()
        self.timeSlotsObservable = timeSlotsVariable.asObservable()
        
        //Only the current day subscribes for new TimeSlots
        guard isCurrentDay else { return }
        
        persistencyService.subscribeToTimeSlotChanges(onNewTimeSlot)
    }
    
    //MARK: Methods
    
    /**
     Updates a TimeSlot's category.
     
     - Parameter category: Category of the newly created TimeSlot.
     */
    func updateTimeSlot(atIndex index: Int, withCategory category: Category) -> Bool
    {
        let timeSlot = timeSlots[index]
        guard persistencyService.updateTimeSlot(timeSlot, withCategory: category) else { return false }
        
        metricsService.log(event: .timeSlotEditing)
        
        timeSlot.category = category
        return true
    }
    
    ///Called when the persistency service indicates that a new TimeSlot has been created.
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
