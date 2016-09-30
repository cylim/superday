import Foundation
@testable import teferi

class MockMetricsService : MetricsService
{
    //MARK: Fields
    private var loggedEvents = [CustomEvent]()
    
    func initialize()
    {
        
    }
    
    func log(event: CustomEvent)
    {
        loggedEvents.append(event)
    }
    
    func didLog(event: CustomEvent) -> Bool
    {
        return loggedEvents.contains(event)
    }
}
