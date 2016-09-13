protocol LocationService
{
    func subscribeToLocationChanges(onLocationCallback: Location -> ())
}