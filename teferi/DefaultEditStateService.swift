import RxSwift

class DefaultEditStateService : EditStateService
{
    //MARK: Fields
    private let isEditingVariable = Variable(false)
    
    //MARK: Initializers
    
    init()
    {
        self.isEditingObservable = self.isEditingVariable.asObservable()
    }
    
    //MARK: EditStateService implementation
    
    let isEditingObservable : Observable<Bool>
    
    var isEditing : Bool
    {
        get { return self.isEditingVariable.value }
        set(value) { self.isEditingVariable.value = value }
    }
}
