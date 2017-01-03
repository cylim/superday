import UIKit
import RxSwift

class OnboardingPage : UIViewController
{
    private(set) var didAppear = false
    private(set) var nextButtonText : String?
    
    private(set) var timeService : TimeService!
    private(set) var settingsService : SettingsService!
    private(set) var appStateService : AppStateService!
    private(set) var notificationService : NotificationService!
    
    var allowPagingSwipe : Bool { return self.nextButtonText != nil }
    
    private(set) var onboardingPageViewController : OnboardingPageViewController!
    
    init?(coder aDecoder: NSCoder, nextButtonText: String?)
    {
        super.init(coder: aDecoder)
        
        self.nextButtonText = nextButtonText
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    func inject(_ timeService: TimeService,
                _ settingsService: SettingsService,
                _ appStateService: AppStateService,
                _ notificationService: NotificationService,
                _ onboardingPageViewController: OnboardingPageViewController)
    {
        self.timeService = timeService
        self.appStateService = appStateService
        self.settingsService = settingsService
        self.notificationService = notificationService
        self.onboardingPageViewController = onboardingPageViewController
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        guard !self.didAppear else { return }
        self.didAppear = true
        
        self.startAnimations()
    }
    
    func finish()
    {
        self.onboardingPageViewController.goToNextPage()
    }
    
    func startAnimations()
    {
        // override in page
    }
    
    @objc func appBecameActive()
    {
        // override in page
    }
    
    func getDate(addingHours hours : Int, andMinutes minutes : Int) -> Date
    {
        return self.timeService.now
            .ignoreTimeComponents()
            .addingTimeInterval(TimeInterval((hours * 60 + minutes) * 60))
    }
    
    func createTimelineCell(for timeSlot: TimeSlot) -> TimelineCell
    {
        let cell = Bundle.main
            .loadNibNamed("TimelineCell", owner: self, options: nil)?
            .first as! TimelineCell
        cell.bind(toTimeSlot: timeSlot, index: 0, lastInPastDay: false)
        return cell
    }
    
    func createTimelineCells(for timeSlots: [TimeSlot]) -> [TimelineCell]
    {
        return timeSlots.map(self.createTimelineCell)
    }
    
    func initAnimatingTimeline(with slots: [TimeSlot], in containingView: UIView) -> [TimelineCell]
    {
        var offset = 0.0
        
        let cells = self.createTimelineCells(for: slots)
        
        for (index, cell) in cells.enumerated()
        {
            containingView.addSubview(cell)
            
            cell.snp.makeConstraints { make in
                make.top.equalTo(containingView).offset(offset)
                make.left.equalTo(containingView)
            }
            
            cell.transform = CGAffineTransform(translationX: 0, y: 15)
            cell.alpha = 0
            
            let slot = slots[index]
            let cellHeight = TimelineViewController.timelineCellHeight(duration: slot.duration, isRunning: slot.endTime != nil)
            
            offset += Double(cellHeight) - 8
        }
        
        return cells
    }
    
    func animateTimeline(_ cells: [TimelineCell], delay initialDelay: TimeInterval)
    {
        var delay = initialDelay
        
        for cell in cells
        {
            UIView.animate(withDuration: 0.6, delay: delay, options: .curveEaseOut, animations:
                {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0)
                    cell.alpha = 1
                },
                completion: nil)
            
            delay += 0.2
        }
    }
    
    func initAnimatedTitleText(_ view: UIView)
    {
        view.transform = CGAffineTransform(translationX: 100, y: 0)
    }
    
    func animateTitleText(_ view: UIView, duration: TimeInterval, delay: TimeInterval)
    {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseOut, animations:
            {
                view.transform = CGAffineTransform(translationX: 0, y: 0)
            },
            completion: nil)
    }
}
