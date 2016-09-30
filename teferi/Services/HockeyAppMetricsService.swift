import HockeySDK

///Implementation of the MetricsService that relies on HockeyApp for analytics
class HockeyAppMetricsService : MetricsService
{
    //MARK: Methods
    
    ///Perform any framework specific initialization
    func initialize()
    {
        BITHockeyManager.shared().configure(withIdentifier: Constants.hockeyAppIdentifier)
        // Do some additional configuration if needed here
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()
    }
    
    ///Used to send custom events to the framework
    func log(event: CustomEvent)
    {
        let metricsManager = BITHockeyManager.shared().metricsManager
        metricsManager.trackEvent(withName: event.rawValue)
    }
}
