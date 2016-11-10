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
    private let timeSlotChangeVariable : Variable<TimeSlotChangeType>
    
    //MARK: Properties
    let date : Date
    let timeObservable : Observable<Int>
    let timeSlotsObservable : Observable<[TimeSlot]>
    let isEditingObservable : Observable<Bool>
    let timeSlotChangeObservable : Observable<TimeSlotChangeType>
    
    var timeSlotChange : TimeSlotChangeType
    {
        get { return self.timeSlotChangeVariable.value }
        set(value) { self.timeSlotChangeVariable.value = value }
    }
    
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
    init(date: Date, metricsService : MetricsService, persistencyService: PersistencyService)
    {
        let isCurrentDay = Date().ignoreTimeComponents() == date.ignoreTimeComponents()
        let timeSlotsForDate = persistencyService.getTimeSlots(forDay: date, last: nil)
        
        //UI gets notified once every n seconds that the last item might need to be redrawn
        self.timeObservable = isCurrentDay ? Observable<Int>.timer(0, period: 10, scheduler: MainScheduler.instance) : Observable.empty()
        
        self.metricsService = metricsService
        self.date = date.ignoreTimeComponents()
        self.persistencyService = persistencyService
        self.timeSlotsVariable = Variable(timeSlotsForDate)
        self.timeSlotChangeVariable = Variable(TimeSlotChangeType.none)
        self.isEditingObservable = self.isEditingVariable.asObservable()
        self.timeSlotsObservable = self.timeSlotsVariable.asObservable()
        self.timeSlotChangeObservable = self.timeSlotChangeVariable.asObservable()
        
        //Only the current day subscribes for new TimeSlots
        guard isCurrentDay else { return }
        
        self.persistencyService.subscribeToTimeSlotChanges(onChangedTimeSlot)
        
        //Creates an empty TimeSlot if there are no TimeSlots for today
        if self.timeSlots.count == 0
        {
            self.persistencyService.addNewTimeSlot(TimeSlot())
            self.timeSlotChange = .create
        }
    }
    
    //MARK: Methods
    
    ///Called when the persistency service indicates that a TimeSlot has been created/updated.
    private func onChangedTimeSlot(timeSlot: TimeSlot, changeType: TimeSlotChangeType)
    {
        switch changeType {
        case .create:
            
            if let lastTimeSlot = timeSlots.last
            {
                lastTimeSlot.endTime = Date()
            }
            self.timeSlots.append(timeSlot)
            self.timeSlotChange = .create
            
        case .update:
            
            if let index = self.timeSlots.index(where: { $0.startTime == timeSlot.startTime })
            {
                self.timeSlots[index] = timeSlot
            }
            self.timeSlotChange = .update
            
        default:
            break
        }
    }}
