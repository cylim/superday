import Foundation
@testable import teferi

class MockLoggingService : LoggingService
{
    func log(withLogLevel logLevel: LogLevel, message: String) { }
    
    func log(withLogLevel logLevel: LogLevel, message: CustomStringConvertible) { }
}
