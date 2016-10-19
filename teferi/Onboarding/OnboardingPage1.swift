import UIKit

class OnboardingPage1 : OnboardingPage
{
    @IBOutlet private weak var textView: UIView!
    
    private var timeSlots : [TimeSlot]!
    private var timelineCells : [TimelineCell]!
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder, nextButtonText: "Let's begin")
        
        self.timeSlots = [
                TimeSlot(category: .leisure, startTime: t(9, 30), endTime: t(10, 0)),
                TimeSlot(category: .work, startTime: t(10, 0), endTime: t(10, 55))
            ]
        self.timelineCells = self.timeSlots.map { slot in
                let cell = Bundle.main
                    .loadNibNamed("TimelineCell", owner: self, options: nil)?
                    .first as! TimelineCell
                cell.bind(toTimeSlot: slot, index: 0)
                return cell
            }
    }
    
    override func viewDidLoad()
    {
        self.textView.transform = CGAffineTransform(translationX: 100, y: 0)
        
        var offset = 24.0
        var index = 0
        
        for cell in self.timelineCells
        {
            self.view.addSubview(cell)
            
            cell.snp.makeConstraints { make in
                make.top.equalTo(self.textView.snp.bottom).offset(offset)
                make.left.equalTo(self.view.snp.left).offset(8)
            }
            
            cell.transform = CGAffineTransform(translationX: 0, y: 15)
            cell.alpha = 0
            
            let slot = self.timeSlots[index]
            let cellHeight = TimelineViewController.timelineCellHeight(duration: slot.duration, isRunning: slot.endTime != nil)
            
            offset += Double(cellHeight)
            index += 1
        }
    }
    
    override func startAnimations()
    {
        UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut, animations:
            {
                self.textView.transform = CGAffineTransform(translationX: 0, y: 0)
            },
            completion: nil)
        
        var delay = 1.3
        
        for cell in self.timelineCells
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
}
