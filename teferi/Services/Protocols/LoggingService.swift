///Service that creates
protocol LoggingService
{
    func log(withLogLevel logLevel: LogLevel, message: String)
    
    func log(withLogLevel logLevel: LogLevel, message: CustomStringConvertible)
}
