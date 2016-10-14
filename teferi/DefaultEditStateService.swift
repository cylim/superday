import RxSwift

class DefaultEditStateService : EditStateService
{
    //MARK: Fields
    private let isEditingVariable = Variable(false)
    private let beganEditingVariable = Variable((CGPoint(), TimeSlot()))
    
    //MARK: Initializers
    
    init()
    {
        self.isEditingObservable = self.isEditingVariable.asObservable()
        self.beganEditingObservable = self.beganEditingVariable.asObservable()
    }
    
    //MARK: EditStateService implementation
    let isEditingObservable : Observable<Bool>
    let beganEditingObservable : Observable<(CGPoint, TimeSlot)>
    
    var isEditing : Bool
    {
        get { return self.isEditingVariable.value }
        set(value) { self.isEditingVariable.value = value }
    }
    
    func notifyEditingBegan(point: CGPoint, timeSlot: TimeSlot)
    {
        self.beganEditingVariable.value = (point, timeSlot)
    }
}
