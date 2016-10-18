import UIKit

class OnboardingPage2 : OnboardingPage
{
    @IBOutlet private weak var textView: UIView!
    
    var timelineCell : TimelineCell!
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder, nextButtonText: "Ok, got it")
        
        self.timelineCell = Bundle.main
            .loadNibNamed("TimelineCell", owner: self, options: nil)?
            .first as! TimelineCell
        self.timelineCell.bind(toTimeSlot: TimeSlot(
            category: .friends, startTime: t(9, 30), endTime: t(10, 0)), index: 0)
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
    }
}
