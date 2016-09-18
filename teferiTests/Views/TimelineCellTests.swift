import Foundation
import XCTest
@testable import teferi

class TimelineCellTests : XCTestCase
{
    // MARK: Fields
    private let timeSlot = TimeSlot(category: .Work)
    private var view = TimelineCell()
    
    private var imageIcon : UIImageView
    {
        let view = self.view.subviews.filter { v in v is UIImageView  }.first!
        return view as! UIImageView
    }
    
    private var slotDescription : UILabel
    {
        let view = self.view.subviews.filter { v in v is UILabel  }.first!
        return view as! UILabel
    }
    
    private var timeLabel : UILabel
    {
        let view = self.view.subviews.filter { v in v is UILabel  }.last!
        return view as! UILabel
    }
    
    private var line : UIView
    {
        return  self.view.subviews.first!
    }
    
    override func setUp()
    {
        view = Bundle.main.loadNibNamed("TimelineCell", owner: nil, options: nil)?.first! as! TimelineCell
        view.bindTimeSlot(timeSlot)
    }
    
    func testTheImageChangesAccordingToTheBoundTimeSlot()
    {
        XCTAssertNotNil(self.imageIcon.image)
    }
    
    func testTheDescriptionChangesAccordingToTheBoundTimeSlot()
    {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        let dateString = formatter.string(from: timeSlot.startTime)
        
        let expectedText = "\(timeSlot.category) \(dateString)"
        XCTAssertEqual(self.slotDescription.text, expectedText)
    }
    
    func testTheDescriptionHasNoCategoryWhenTheCategoryIsUnknown()
    {
        let unknownTimeSlot = TimeSlot()
        view.bindTimeSlot(unknownTimeSlot)
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        let dateString = formatter.string(from: unknownTimeSlot.startTime)
        
        let expectedText = " \(dateString)"
        XCTAssertEqual(self.slotDescription.text, expectedText)
    }
    
    func testTheElapsedTimeLabelShowsOnlyMinutesWhenLessThanAnHourHasPassed()
    {
        let minuteMask = "%02d min"
        let interval = Int(timeSlot.duration)
        let minutes = (interval / 60) % 60
        
        let expectedText = String(format: minuteMask, minutes)
        XCTAssertEqual(self.timeLabel.text, expectedText)
    }
    
    func testTheElapsedTimeLabelShowsHoursAndMinutesWhenOverAnHourHasPassed()
    {
        let newTimeSlot = TimeSlot()
        newTimeSlot.startTime = Date().yesterday
        view.bindTimeSlot(newTimeSlot)
        
        let hourMask = "%02d h %02d min"
        let interval = Int(newTimeSlot.duration)
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        
        let expectedText = String(format: hourMask, hours, minutes)
        XCTAssertEqual(self.timeLabel.text, expectedText)
    }
    
    func testTheElapsedTimeLabelColorChangesAccordingToTheBoundTimeSlot()
    {
        let expectedColor = Category.Work.color
        let actualColor = timeLabel.textColor!
        
        var expectedRed : CGFloat = 0, expectedGreen : CGFloat = 0, expectedBlue : CGFloat = 0, expectedAlpha : CGFloat = 0
        expectedColor.getRed(&expectedRed, green: &expectedGreen, blue: &expectedBlue, alpha: &expectedAlpha)
        
        var actualRed : CGFloat = 0, actualGreen : CGFloat = 0, actualBlue : CGFloat = 0, actualAlpha : CGFloat = 0
        actualColor.getRed(&actualRed, green: &actualGreen, blue: &actualBlue, alpha: &actualAlpha)
        
        XCTAssertEqual(expectedRed, actualRed)
        XCTAssertEqual(expectedGreen, actualGreen)
        XCTAssertEqual(expectedBlue, actualBlue)
    }
    
    func testTheTimelineCellLineHeightChangesAccordingToTheBoundTimeSlot()
    {
        let oldLineHeight = line.frame.height
        let newTimeSlot = TimeSlot()
        newTimeSlot.startTime = Date().add(days: -1)
        newTimeSlot.endTime = Date()
        view.bindTimeSlot(newTimeSlot)
        view.layoutIfNeeded()
        let newLineHeight = line.frame.height
        
        XCTAssertLessThan(oldLineHeight, newLineHeight)
    }
    
    func testTheLineColorChangesAccordingToTheBoundTimeSlot()
    {
        let expectedColor = Category.Work.color
        let actualColor = line.backgroundColor!
        
        var expectedRed : CGFloat = 0, expectedGreen : CGFloat = 0, expectedBlue : CGFloat = 0, expectedAlpha : CGFloat = 0
        expectedColor.getRed(&expectedRed, green: &expectedGreen, blue: &expectedBlue, alpha: &expectedAlpha)
        
        var actualRed : CGFloat = 0, actualGreen : CGFloat = 0, actualBlue : CGFloat = 0, actualAlpha : CGFloat = 0
        actualColor.getRed(&actualRed, green: &actualGreen, blue: &actualBlue, alpha: &actualAlpha)
        
        XCTAssertEqual(expectedRed, actualRed)
        XCTAssertEqual(expectedGreen, actualGreen)
        XCTAssertEqual(expectedBlue, actualBlue)
    }
}
