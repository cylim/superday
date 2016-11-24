import Foundation
import RxSwift

///ViewModel for the TimelineViewController.
class TimelineViewModel
{
    //MARK: Fields
    private let metricsService : MetricsService
    private let timeSlotService : TimeSlotService
    private let isEditingVariable = Variable(false)
    private let timeSlotUpdatingVariable = Variable(-1)
    private let timeSlotCreationVariable = Variable(-1)
    
    //MARK: Properties
    let date : Date
    let timeObservable : Observable<Int>
    let isEditingObservable : Observable<Bool>
    let timeSlotUpdatingObservable : Observable<Int>
    let timeSlotCreationObservable : Observable<Int>
    
    private(set) var timeSlots : [TimeSlot]
    
    var isEditing : Bool
    {
        get { return self.isEditingVariable.value }
        set(value) { self.isEditingVariable.value = value }
    }
    
    //MARK: Initializers
    init(date: Date, metricsService : MetricsService, timeSlotService: TimeSlotService)
    {
        let isCurrentDay = Date().ignoreTimeComponents() == date.ignoreTimeComponents()
        self.timeSlots = timeSlotService.getTimeSlots(forDay: date)
        
        //UI gets notified once every n seconds that the last item might need to be redrawn
        self.timeObservable = isCurrentDay ? Observable<Int>.timer(0, period: 10, scheduler: MainScheduler.instance) : Observable.empty()
        
        self.metricsService = metricsService
        self.timeSlotService = timeSlotService
        self.date = date.ignoreTimeComponents()
        self.isEditingObservable = self.isEditingVariable.asObservable()
        self.timeSlotCreationObservable = self.timeSlotCreationVariable.asObservable()
        self.timeSlotUpdatingObservable = self.timeSlotUpdatingVariable.asObservable().filter { $0 >= 0 }
        
        //Only the current day subscribes for new TimeSlots
        guard isCurrentDay else { return }
        
        self.timeSlotService.subscribeToTimeSlotChanges(on: .create, self.onTimeSlotCreated)
        self.timeSlotService.subscribeToTimeSlotChanges(on: .update, self.onTimeSlotUpdated)
        
        //Creates an empty TimeSlot if there are no TimeSlots for today
        if self.timeSlots.count == 0
        {
            self.timeSlotService.add(timeSlot: TimeSlot())
        }
    }
    
    //MARK: Methods
    
    ///Called when the persistency service indicates that a TimeSlot has been created/updated.
    private func onTimeSlotCreated(timeSlot: TimeSlot)
    {
        //Finishes last task, if needed
        if let lastTimeSlot = self.timeSlots.last
        {
            lastTimeSlot.endTime = Date()
        }
        
        self.timeSlots.append(timeSlot)
        self.timeSlotCreationVariable.value = self.timeSlots.count - 1
    }
    
    private func onTimeSlotUpdated(timeSlot: TimeSlot)
    {
        if let index = self.timeSlots.index(where: { $0.startTime == timeSlot.startTime })
        {
            self.timeSlots[index] = timeSlot
            self.timeSlotUpdatingVariable.value = index
        }
    }
}
