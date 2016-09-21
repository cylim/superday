import SwiftyBeaver

/// Implementation of LoggingService that depends on the SwiftyBeaver library
class SwiftyBeaverLoggingService : LoggingService
{
    //MARK: Fields
    private let swiftBeaver = SwiftyBeaver.self

    //MARK: Initializers
    init()
    {
        let file = FileDestination()
        file.format = "$Dyyyy-MM-dd HH:mm:ss.fff:$d $L => $M"
        swiftBeaver.addDestination(file)
    }
    
    //MARK: LoggingService implementation
    func log(withLogLevel logLevel: LogLevel, message: String)
    {
        switch logLevel
        {
            case .verbose:
                swiftBeaver.verbose(message)
            case .debug:
                swiftBeaver.debug(message)
            case .info:
                swiftBeaver.info(message)
            case .warning:
                swiftBeaver.warning(message)
            case .error:
                swiftBeaver.error(message)
        }
    }
    
    func log(withLogLevel logLevel: LogLevel, message: CustomStringConvertible)
    {
        log(withLogLevel: logLevel, message: message.description)
    }
}
