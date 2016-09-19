import SwiftyBeaver

/// Implementation of LoggingService that depends on the SwiftyBeaver library
class SwiftyBeaverLoggingService : LoggingService
{
    //MARK: Static properties
    static let instance = SwiftyBeaverLoggingService()

    //MARK: Fields
    private let swiftBeaver = SwiftyBeaver.self

    //MARK: Initializers
    private init()
    {
        let file = FileDestination()
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
