import XCTest
import Nimble
import RxSwift
@testable import teferi

class TimelineViewControllerTests : XCTestCase
{
    private var viewModel : TimelineViewModel!
    private var mockMetricsService : MockMetricsService!
    private var mockAppStateService : MockAppStateService!
    private var mockTimeSlotService : MockTimeSlotService!
    private var mockEditStateService : MockEditStateService!
    private var timelineViewController : TimelineViewController!
    
    override func setUp()
    {
        super.setUp()
        
        self.mockMetricsService = MockMetricsService()
        self.mockAppStateService = MockAppStateService()
        self.mockTimeSlotService = MockTimeSlotService()
        self.mockEditStateService = MockEditStateService()
        
        self.viewModel = TimelineViewModel(date: Date(),
                                           metricsService: self.mockMetricsService,
                                           appStateService: self.mockAppStateService,
                                           timeSlotService: self.mockTimeSlotService)
        
        self.timelineViewController = TimelineViewController(date: Date(),
                                                             metricsService: self.mockMetricsService,
                                                             appStateService: self.mockAppStateService,
                                                             timeSlotService: self.mockTimeSlotService,
                                                             editStateService: self.mockEditStateService)
    }
    
    override func tearDown()
    {
        super.tearDown()
        
        self.timelineViewController.viewWillDisappear(false)
        self.timelineViewController = nil
    }
    
    func testScrollingIsDisabledWhenEnteringEditMode()
    {
        self.mockEditStateService.notifyEditingBegan(point: CGPoint(), timeSlot: TimeSlot(withStartTime: Date(), categoryWasSetByUser: false));
        
        let scrollView = self.timelineViewController.tableView!
        
        expect(scrollView.isScrollEnabled).to(beFalse())
    }
    
    func testScrollingIsEnabledWhenExitingEditMode()
    {
        self.mockEditStateService.notifyEditingBegan(point: CGPoint(), timeSlot: TimeSlot(withStartTime: Date(), categoryWasSetByUser: false));
        self.mockEditStateService.notifyEditingEnded();
        
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
