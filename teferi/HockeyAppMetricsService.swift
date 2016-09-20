import HockeySDK

///Implementation of the MetricsService that relies on HockeyApp for analytics
class HockeyAppMetricsService : MetricsService
{
    //MARK: Methods
    
    ///Perform any framework specific initialization
    func initialize()
    {
        BITHockeyManager.shared().configure(withIdentifier: "{HockeyAppIdentifier}")
        // Do some additional configuration if needed here
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()
    }
    
    ///Used to send custom events to the framework
    func log(customEvent event: CustomEvent)
    {
        //TODO: Add loggin of custom events once their UI is added
    }
}
