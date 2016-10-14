import RxSwift
import CoreGraphics

protocol EditStateService
{
    var isEditing : Bool { get set }
    
    var isEditingObservable : Observable<Bool> { get }
    
    var beganEditingObservable : Observable<(CGPoint, TimeSlot)> { get }
    
    func notifyEditingBegan(point: CGPoint, timeSlot: TimeSlot)
}
