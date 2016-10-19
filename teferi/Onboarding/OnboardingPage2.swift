import UIKit

class OnboardingPage2 : OnboardingPage
{
    @IBOutlet private weak var textView: UIView!
    
    private var timeSlot : TimeSlot!
    private var timelineCell : TimelineCell!
    private var editView : EditTimeSlotView!
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder, nextButtonText: "Ok, got it")
        
        self.timeSlot = TimeSlot(category: .friends, startTime: t(9, 30), endTime: t(10, 0))
        
        self.timelineCell = Bundle.main
            .loadNibNamed("TimelineCell", owner: self, options: nil)?
            .first as! TimelineCell
        self.timelineCell.bind(toTimeSlot: self.timeSlot, index: 0)
        
        self.editView = EditTimeSlotView(frame: self.timelineCell.bounds, editEndedCallback: { _,_ in })
        self.editView.isUserInteractionEnabled = false
        self.timelineCell.addSubview(self.editView)
    }
    
    override func viewDidLoad()
    {
        self.textView.transform = CGAffineTransform(translationX: 100, y: 0)
        
        self.view.addSubview(self.timelineCell)
        
        self.timelineCell.snp.makeConstraints { make in
            make.top.equalTo(self.textView.snp.bottom).offset(24)
            make.left.equalTo(self.view.snp.left).offset(8)
        }
        
        self.timelineCell.transform = CGAffineTransform(translationX: 0, y: 15)
        self.timelineCell.alpha = 0
    }
    
    override func startAnimations()
    {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations:
            {
                self.textView.transform = CGAffineTransform(translationX: 0, y: 0)
            },
            completion: nil)
        
        UIView.animate(withDuration: 0.6, delay: 0.3, options: .curveEaseOut, animations:
            {
                self.timelineCell.transform = CGAffineTransform(translationX: 0, y: 0)
                self.timelineCell.alpha = 1
            },
            completion: nil)
        
        Timer.schedule(withDelay: 1.2, handler: { _ in
            self.editView.onEditBegan(
                point: self.timelineCell.categoryIcon!.convert(self.timelineCell.categoryIcon!.center, to: self.timelineCell),
                timeSlot: self.timeSlot)
        })
    }
}
