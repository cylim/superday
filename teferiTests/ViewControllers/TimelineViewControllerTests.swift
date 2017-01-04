import XCTest
import Nimble
import RxSwift
@testable import teferi

class TimelineViewControllerTests : XCTestCase
{
    private var locator : MockLocator!
    private var viewModel : TimelineViewModel!
    private var timelineViewController : TimelineViewController!
    
    override func setUp()
    {
        super.setUp()
        
        self.locator = MockLocator()
        
        self.viewModel = self.locator.getTimelineViewModel(forDate: Date())
        
        self.timelineViewController = TimelineViewController(viewModel: self.viewModel)
    }
    
    override func tearDown()
    {
        super.tearDown()
        
        self.timelineViewController.viewWillDisappear(false)
        self.timelineViewController = nil
    }
    
    func testScrollingIsDisabledWhenEnteringEditMode()
    {
        self.locator.editStateService.notifyEditingBegan(point: CGPoint(),
                                                         timeSlot: TimeSlot(withStartTime: Date(), categoryWasSetByUser: false));
        
        let scrollView = self.timelineViewController.tableView!
        
        expect(scrollView.isScrollEnabled).to(beFalse())
    }
    
    func testScrollingIsEnabledWhenExitingEditMode()
    {
        self.locator.editStateService.notifyEditingBegan(point: CGPoint(), timeSlot: TimeSlot(withStartTime: Date(), categoryWasSetByUser: false));
        self.locator.editStateService.notifyEditingEnded();
        
        let scrollView = self.timelineViewController.tableView!
        
        expect(scrollView.isScrollEnabled).to(beTrue())
    }
    
    func testUIRefreshesAsTimePasses()
    {
        let indexPath = IndexPath(row: self.viewModel.timeSlots.count - 1, section: 0)
        let cell = self.timelineViewController.tableView(self.timelineViewController.tableView, cellForRowAt: indexPath) as! TimelineCell
        let elapsedTimeLabel = cell.subviews[4] as! UILabel
        let beforeElapsedTimeText = elapsedTimeLabel.text
        
        //71 sec. are needed to pass in order to see changes in the UI
        RunLoop.current.run(until: Date().addingTimeInterval(71))
        
        expect(elapsedTimeLabel.text).toNot(equal(beforeElapsedTimeText))
    }
}
