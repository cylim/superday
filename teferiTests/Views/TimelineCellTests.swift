import Foundation
import XCTest
import Nimble
@testable import teferi

class TimelineCellTests : XCTestCase
{
    // MARK: Fields
    private let timeSlot = TimeSlot(category: .work)
    private var view : TimelineCell!
    
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
        self.view = Bundle.main.loadNibNamed("TimelineCell", owner: nil, options: nil)?.first! as! TimelineCell
        self.view.bind(toTimeSlot: timeSlot, shouldFade: false, index: 0, isEditingCategory: false)
    }
    
    override func tearDown()
    {
        self.timeSlot.category = .work
    }
    
    private func editCellSetUp(_ shouldFade: Bool = true, isEditingCategory: Bool = true)
    {
        self.view.bind(toTimeSlot: timeSlot, shouldFade: shouldFade, index: 0, isEditingCategory: isEditingCategory)
    }
    
    func testTheImageChangesAccordingToTheBoundTimeSlot()
    {
        expect(self.imageIcon.image).toNot(beNil())
    }
    
    func testTheDescriptionChangesAccordingToTheBoundTimeSlot()
    {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        let dateString = formatter.string(from: timeSlot.startTime)
        
        let expectedText = "\(timeSlot.category) \(dateString)"
        
        expect(self.slotDescription.text).to(equal(expectedText))
    }
    
    func testTheDescriptionHasNoCategoryWhenTheCategoryIsUnknown()
    {
        let unknownTimeSlot = TimeSlot()
        view.bind(toTimeSlot: unknownTimeSlot, shouldFade: false, index: 0, isEditingCategory: false)
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        let dateString = formatter.string(from: unknownTimeSlot.startTime)
        
        let expectedText = " \(dateString)"
        
        expect(self.slotDescription.text).to(equal(expectedText))
    }
    
    func testTheElapsedTimeLabelShowsOnlyMinutesWhenLessThanAnHourHasPassed()
    {
        let minuteMask = "%02d min"
        let interval = Int(timeSlot.duration)
        let minutes = (interval / 60) % 60
        
        let expectedText = String(format: minuteMask, minutes)
        
        expect(self.timeLabel.text).to(equal(expectedText))
    }
    
    func testTheElapsedTimeLabelShowsHoursAndMinutesWhenOverAnHourHasPassed()
    {
        let newTimeSlot = TimeSlot()
        newTimeSlot.startTime = Date().yesterday
        self.view.bind(toTimeSlot: newTimeSlot, shouldFade: false, index: 0, isEditingCategory: false)
        
        let hourMask = "%02d h %02d min"
        let interval = Int(newTimeSlot.duration)
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        
        let expectedText = String(format: hourMask, hours, minutes)
        
        expect(self.timeLabel.text).to(equal(expectedText))
    }
    
    func testTheElapsedTimeLabelColorChangesAccordingToTheBoundTimeSlot()
    {
        let expectedColor = Category.work.color
        let actualColor = timeLabel.textColor!
        
        expect(expectedColor).to(equal(actualColor))
    }
    
    func testTheTimelineCellLineHeightChangesAccordingToTheBoundTimeSlot()
    {
        let oldLineHeight = self.line.frame.height
        let newTimeSlot = TimeSlot()
        newTimeSlot.startTime = Date().add(days: -1)
        newTimeSlot.endTime = Date()
        self.view.bind(toTimeSlot: newTimeSlot, shouldFade: false, index: 0, isEditingCategory: false)
        self.view.layoutIfNeeded()
        let newLineHeight = line.frame.height
        
        expect(oldLineHeight).to(beLessThan(newLineHeight))
    }
    
    func testTheLineColorChangesAccordingToTheBoundTimeSlot()
    {
        let expectedColor = Category.work.color
        let actualColor = self.line.backgroundColor!
        
        expect(expectedColor).to(equal(actualColor))
    }
    
    func testTheLineFadesWhenTheShouldFadeParametersIsTrue()
    {
        self.editCellSetUp()
        
        expect(self.line.alpha).to(beCloseTo(Constants.editingAlpha, within: 0.01))
    }
    
    func testTheTimeLabelFadesWhenTheShouldFadeParametersIsTrue()
    {
        self.editCellSetUp()
        
        expect(self.timeLabel.alpha).to(beCloseTo(Constants.editingAlpha, within: 0.01))
    }
    
    func testTheSlotDescriptionFadesWhenTheShouldFadeParametersIsTrue()
    {
        self.editCellSetUp()
        
        expect(self.slotDescription.alpha).to(beCloseTo(Constants.editingAlpha, within: 0.01))
    }
    
    func testTheCategoryIconDoesNotFadesWhenTheShouldFadeParametersIsTrueButTheCategoryIsBeingEdited()
    {
        self.editCellSetUp()
        
        expect(self.imageIcon.alpha).to(equal(1.0))
    }
    
    func testTheCategoryIconDoesFadesWhenTheShouldFadeParametersIsTrueAndTheCategoryIsNotBeingEdited()
    {
        self.editCellSetUp(true, isEditingCategory: false)
        
        expect(self.imageIcon.alpha).to(beCloseTo(Constants.editingAlpha, within: 0.01))
    }
    
    func testBindingTheCellForEditingShowsAllPossibleCategoriesIfTheTimeSlotIsUnknown()
    {
        let numberOfViews = view.subviews.count
        timeSlot.category = .unknown
        self.editCellSetUp()
        
        expect(self.view.subviews.count).to(equal(numberOfViews + 5))
    }
    
    func testBindingTheCellForEditingShowsAllPossibleCategoriesExceptTheCurrentOne()
    {
        let numberOfViews = view.subviews.count
        self.editCellSetUp()
        
        expect(self.view.subviews.count).to(equal(numberOfViews + 4))
    }
    
    func testRebindingACellAfterEditingRemovesTheExtraViews()
    {
        let numberOfViewsBeforeBinding = view.subviews.count
        self.editCellSetUp()
        self.editCellSetUp(true, isEditingCategory: false)
        
        expect(self.view.subviews.count).to(equal(numberOfViewsBeforeBinding))
    }
}
