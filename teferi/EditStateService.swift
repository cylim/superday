import RxSwift

protocol EditStateService
{
    var isEditing : Bool { get set }
    
    var isEditingObservable : Observable<Bool> { get }
}
