import RxSwift

protocol AppStateService
{
    var currentAppState : AppState { get set }
    
    var appStateObservable : Observable<AppState> { get }
}
