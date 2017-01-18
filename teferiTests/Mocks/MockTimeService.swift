@testable import teferi
import Foundation

class MockTimeService : TimeService
{
	var mockDate : Date? = Date().ignoreTimeComponents().addingTimeInterval(12 * 60 * 60)

    var now : Date { return mockDate ?? Date()  }
}
