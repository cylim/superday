import Foundation
import RxSwift

///ViewModel for the TimelineViewController.
class TimelineViewModel
{
    //MARK: Fields
    private let isCurrentDay : Bool
    private let disposeBag = DisposeBag()
    
    private let timeService : TimeService
    private let metricsService : MetricsService
    private let appStateService : AppStateService
    private let timeSlotService : TimeSlotService
    private let editStateService : EditStateService
    private let timeSlotUpdatingVariable = Variable(-1)
    private let timeSlotCreationVariable = Variable(-1)
    
    //MARK: Properties
    let date : Date
    let timeObservable : Observable<Int>
    let timeSlotUpdatingObservable : Observable<Int>
    let timeSlotCreationObservable : Observable<Int>
    
    private(set) lazy var refreshScreenObservable : Observable<Void> =
    {
        guard self.isCurrentDay else { return Observable.empty() }
        
        return
            self.appStateService
                .appStateObservable
                .filter(self.filterRefreshStates)
                .map(self.refreshTimeSlotsFromService)
    }()

    private(set) var timeSlots : [TimeSlot]
    {
        didSet
        {
            self.processTimeSlots(self.timeSlots)
        }
    }
    
    var currentDay : Date { return self.timeService.now }
    var isEditingObservable : Observable<Bool> { return self.editStateService.isEditingObservable }
    
    //MARK: Initializers
    init(date: Date,
         timeService: TimeService,
         metricsService : MetricsService,
         appStateService: AppStateService,
         timeSlotService: TimeSlotService,
         editStateService: EditStateService)
    {
        self.timeService = timeService
        self.metricsService = metricsService
        self.appStateService = appStateService
        self.timeSlotService = timeSlotService
        self.editStateService = editStateService
        
        self.isCurrentDay = self.timeService.now.ignoreTimeComponents() == date.ignoreTimeComponents()
        self.timeSlots = timeSlotService.getTimeSlots(forDay: date)
        
        self.date = date.ignoreTimeComponents()

        self.timeSlotCreationObservable = self.timeSlotCreationVariable.asObservable()
        self.timeSlotUpdatingObservable = self.timeSlotUpdatingVariable.asObservable().filter { $0 >= 0 }
        
        self.timeObservable =
            self.isCurrentDay ?
                Observable<Int>.timer(0, period: 10, scheduler: MainScheduler.instance) :
                Observable.empty()
        
        self.processTimeSlots(self.timeSlots)
        
        //Only the current day subscribes for new TimeSlots
        guard self.isCurrentDay else { return }
        
        self.timeSlotService
            .timeSlotCreatedObservable
            .subscribe(onNext: self.onTimeSlotCreated)
            .addDisposableTo(self.disposeBag)
            
        self.timeSlotService
            .timeSlotUpdatedObservable
            .subscribe(onNext: self.onTimeSlotUpdated)
            .addDisposableTo(self.disposeBag)
        
        //Creates an empty TimeSlot if there are no TimeSlots for today
        if self.timeSlots.count == 0
        {
            self.timeSlotService.add(timeSlot: TimeSlot(withStartTime: self.timeService.now, categoryWasSetByUser: false))
        }
    }
    
    func notifyEditingBegan(point: CGPoint, index: Int)
    {
        self.editStateService
            .notifyEditingBegan(point: point,
                                timeSlot: self.timeSlots[index])
    }
    
    //MARK: Methods
    func calculateDuration(ofTimeSlot timeSlot: TimeSlot) -> TimeInterval
    {
        return self.timeSlotService.calculateDuration(ofTimeSlot: timeSlot)
    }
    
    ///Called when the persistency service indicates that a TimeSlot has been created/updated.
    private func onTimeSlotCreated(timeSlot: TimeSlot)
    {
        //Finishes last task, if needed
        if let lastTimeSlot = self.timeSlots.last
        {
            lastTimeSlot.endTime = self.timeService.now
        }
        
        timeSlot.shouldDisplayCategoryName =
            self.shouldDisplayCategoryName(currentTimeSlot: timeSlot, previousTimeSlot: self.timeSlots.last)
        self.timeSlots.append(timeSlot)
        self.timeSlotCreationVariable.value = self.timeSlots.count - 1
    }
    
    private func onTimeSlotUpdated(timeSlot: TimeSlot)
    {
        if let index = self.timeSlots.index(where: { $0.startTime == timeSlot.startTime })
        {
            self.timeSlots[index] = timeSlot
            self.processTimeSlots(self.timeSlots)
        }
    }
    
    private func filterRefreshStates(_ appState: AppState) -> Bool { return appState == .active }
    
    private func refreshTimeSlotsFromService(_ appState: AppState) -> Void
    {
        self.timeSlots = self.timeSlotService.getTimeSlots(forDay: self.date)
    }
    
    private func processTimeSlots(_ timeSlots: [TimeSlot])
    {
        var changedIndexes = [Int]()
        var previousTimeSlot : TimeSlot? = nil
        for (index, timeSlot) in timeSlots.enumerated()
        {
            let oldValue = timeSlot.shouldDisplayCategoryName
            let newValue = self.shouldDisplayCategoryName(currentTimeSlot: timeSlot, previousTimeSlot: previousTimeSlot)

            timeSlot.shouldDisplayCategoryName = newValue
            
            if oldValue != newValue
            {
                changedIndexes.append(index)
            }
            
            previousTimeSlot = timeSlot
        }
        
        changedIndexes.forEach { index in self.timeSlotUpdatingVariable.value = index }
    }
    
    private func shouldDisplayCategoryName(currentTimeSlot: TimeSlot, previousTimeSlot: TimeSlot?) -> Bool
    {
        guard let previous = previousTimeSlot else { return true }
        
        return previous.category != currentTimeSlot.category
    }
}
