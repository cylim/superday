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
        get { return self.isEditingVariable.value }
        set(value) { self.isEditingVariable.value = value }
    }
    
    private(set) var timeSlots : [TimeSlot]
    {
        get { return self.timeSlotsVariable.value }
        set(value) { self.timeSlotsVariable.value = value }
    }
    
    //MARK: Initializers
    init(date: Date, persistencyService: PersistencyService, metricsService : MetricsService)
    {
        let isCurrentDay = Date().ignoreTimeComponents() == date.ignoreTimeComponents()
        let timeSlotsForDate = persistencyService.getTimeSlots(forDay: date)
        
        //UI gets notified once every n seconds that the last item might need to be redrawn
        self.timeObservable = isCurrentDay ? Observable<Int>.timer(0, period: 10, scheduler: MainScheduler.instance) : Observable.empty()
        
        self.date = date
        self.metricsService = metricsService
        self.persistencyService = persistencyService
        self.timeSlotsVariable = Variable(timeSlotsForDate)
        self.isEditingObservable = self.isEditingVariable.asObservable()
        self.timeSlotsObservable = self.timeSlotsVariable.asObservable()
        
        //Only the current day subscribes for new TimeSlots
        guard isCurrentDay else { return }
        
        self.persistencyService.subscribeToTimeSlotChanges(onNewTimeSlot)
    }
    
    //MARK: Methods
    
    /**
     Updates a TimeSlot's category.
     
     - Parameter category: Category of the newly created TimeSlot.
     */
    @discardableResult func updateTimeSlot(atIndex index: Int, withCategory category: Category) -> Bool
    {
        let timeSlot = timeSlots[index]
        guard self.persistencyService.updateTimeSlot(timeSlot, withCategory: category) else { return false }
        
        self.metricsService.log(event: .timeSlotEditing)
        
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
        
        self.timeSlots.append(timeSlot)
    }
}
