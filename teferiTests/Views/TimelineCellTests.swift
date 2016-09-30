import Foundation
import XCTest
@testable import teferi

class TimelineCellTests : XCTestCase
{
    // MARK: Fields
    private let timeSlot = TimeSlot(category: .work)
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
        view.bind(toTimeSlot: timeSlot, shouldFade: false, index: 0, isEditingCategory: false)
    }
    
    override func tearDown()
    {
        timeSlot.category = .work
    }
    
    private func editCellSetUp(_ shouldFade: Bool = true, isEditingCategory: Bool = true)
    {
        view.bind(toTimeSlot: timeSlot, shouldFade: shouldFade, index: 0, isEditingCategory: isEditingCategory)
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
        view.bind(toTimeSlot: unknownTimeSlot, shouldFade: false, index: 0, isEditingCategory: false)
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
        view.bind(toTimeSlot: newTimeSlot, shouldFade: false, index: 0, isEditingCategory: false)
        
        let hourMask = "%02d h %02d min"
        let interval = Int(newTimeSlot.duration)
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        
        let expectedText = String(format: hourMask, hours, minutes)
        XCTAssertEqual(self.timeLabel.text, expectedText)
    }
    
    func testTheElapsedTimeLabelColorChangesAccordingToTheBoundTimeSlot()
    {
        let expectedColor = Category.work.color
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
        view.bind(toTimeSlot: newTimeSlot, shouldFade: false, index: 0, isEditingCategory: false)
        view.layoutIfNeeded()
        let newLineHeight = line.frame.height
        
        XCTAssertLessThan(oldLineHeight, newLineHeight)
    }
    
    func testTheLineColorChangesAccordingToTheBoundTimeSlot()
    {
        let expectedColor = Category.work.color
        let actualColor = line.backgroundColor!
        
        var expectedRed : CGFloat = 0, expectedGreen : CGFloat = 0, expectedBlue : CGFloat = 0, expectedAlpha : CGFloat = 0
        expectedColor.getRed(&expectedRed, green: &expectedGreen, blue: &expectedBlue, alpha: &expectedAlpha)
        
        var actualRed : CGFloat = 0, actualGreen : CGFloat = 0, actualBlue : CGFloat = 0, actualAlpha : CGFloat = 0
        actualColor.getRed(&actualRed, green: &actualGreen, blue: &actualBlue, alpha: &actualAlpha)
        
        XCTAssertEqual(expectedRed, actualRed)
        XCTAssertEqual(expectedGreen, actualGreen)
        XCTAssertEqual(expectedBlue, actualBlue)
    }
    
    func testTheLineFadesWhenTheShouldFadeParametersIsTrue()
    {
        editCellSetUp()
        
        XCTAssertEqualWithAccuracy(line.alpha, Constants.editingAlpha, accuracy: 0.01)
    }
    
    func testTheTimeLabelFadesWhenTheShouldFadeParametersIsTrue()
    {
        editCellSetUp()
        
        XCTAssertEqualWithAccuracy(timeLabel.alpha, Constants.editingAlpha, accuracy: 0.01)
    }
    
    func testTheSlotDescriptionFadesWhenTheShouldFadeParametersIsTrue()
    {
        editCellSetUp()
        
        XCTAssertEqualWithAccuracy(slotDescription.alpha, Constants.editingAlpha, accuracy: 0.01)
    }
    
    func testTheCategoryIconDoesNotFadesWhenTheShouldFadeParametersIsTrueButTheCategoryIsBeingEdited()
    {
        editCellSetUp()
        
        XCTAssertEqual(imageIcon.alpha, 1.0)
    }
    
    func testTheCategoryIconDoesFadesWhenTheShouldFadeParametersIsTrueAndTheCategoryIsNotBeingEdited()
    {
        editCellSetUp(true, isEditingCategory: false)
        
        XCTAssertEqualWithAccuracy(imageIcon.alpha, Constants.editingAlpha, accuracy: 0.01)
    }
    
    func testBindingTheCellForEditingShowsAllPossibleCategoriesIfTheTimeSlotIsUnknown()
    {
        let numberOfViews = view.subviews.count
        timeSlot.category = .unknown
        editCellSetUp()
        
        XCTAssertEqual(view.subviews.count, numberOfViews + 5)
    }
    
    func testBindingTheCellForEditingShowsAllPossibleCategoriesExceptTheCurrentOne()
    {
        let numberOfViews = view.subviews.count
        editCellSetUp()
        
        XCTAssertEqual(view.subviews.count, numberOfViews + 4)
    }
    
    func testRebindingACellAfterEditingRemovesTheExtraViews()
    {
        let numberOfViewsBeforeBinding = view.subviews.count
        editCellSetUp()
        editCellSetUp(true, isEditingCategory: false)
        
        XCTAssertEqual(view.subviews.count, numberOfViewsBeforeBinding)
    }
}
