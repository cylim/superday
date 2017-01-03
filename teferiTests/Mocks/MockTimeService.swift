@testable import teferi
import Foundation

class MockTimeService : TimeService
{
    var now = Date()
}
