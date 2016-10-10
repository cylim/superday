import Fabric
import Crashlytics

class FabricMetricsService : MetricsService
{
    ///Perform any framework specific initialization
    func initialize()
    {
        Fabric.sharedSDK().debug = true
        Fabric.with([Answers.self, Crashlytics.self])
    }
    
    ///Used to send custom events to the framework
    func log(event: CustomEvent)
    {
        Answers.logCustomEvent(withName: event.rawValue, customAttributes: [:])
    }
}
