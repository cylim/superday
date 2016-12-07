import UIKit

class OnboardingPage1 : OnboardingPage
{
    @IBOutlet private weak var textView: UIView!
    @IBOutlet private weak var timelineView: UIView!
    
    private var timeSlots : [TimeSlot]!
    private var timelineCells : [TimelineCell]!
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder, nextButtonText: "Next")
        
        self.timeSlots = [
            TimeSlot(withStartTime: t(9, 30), endTime: t(10, 0), category: .leisure, categoryWasSetByUser: false),
            TimeSlot(withStartTime: t(10, 0), endTime: t(10, 55), category: .work, categoryWasSetByUser: false)
        ]
    }
    
    override func viewDidLoad()
    {
        self.initAnimatedTitleText(self.textView)
        self.timelineCells = self.initAnimatingTimeline(with: self.timeSlots, in: self.timelineView)
    }
    
    override func startAnimations()
    {
        self.animateTitleText(self.textView, duration: 1, delay: 1)
        self.animateTimeline(self.timelineCells, delay: 1.3)
    }
}
