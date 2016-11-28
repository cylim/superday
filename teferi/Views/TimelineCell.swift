import UIKit
import CoreGraphics
import SnapKit
import RxSwift

///Cell that represents a TimeSlot in the timeline
class TimelineCell : UITableViewCell
{
    // MARK: Fields
    private var currentIndex = 0
    private let hourMask = "%02d h %02d min"
    private let minuteMask = "%02d min"
    private lazy var lineHeightConstraint : NSLayoutConstraint =
    {
        return self.lineView.constraints.filter{ $0.firstAttribute == .height }.first!
    }()
    
    @IBOutlet private weak var lineView : UIView!
    @IBOutlet private weak var elapsedTime : UILabel!
    @IBOutlet private weak var indicatorDot : UIView!
    @IBOutlet private weak var categoryButton : UIButton!
    @IBOutlet private weak var slotDescription : UILabel!
    @IBOutlet weak var categoryIcon : UIImageView!
    
    //MARK: Properties
    private(set) var isSubscribedToClickObservable = false
    lazy var editClickObservable : Observable<(CGPoint, Int)> =
    {
        self.isSubscribedToClickObservable = true
        
        return self.categoryButton.rx.tap
            .map { return (self.categoryIcon.convert(self.categoryIcon.center, to: nil), self.currentIndex) }
            .asObservable()
    }()
    
    // MARK: Methods
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.contentView.isUserInteractionEnabled = false
    }
    
    /**
     Binds the current TimeSlot in order to change the UI accordingly.
     
     - Parameter timeSlot: TimeSlot that will be bound.
     */
    func bind(toTimeSlot timeSlot: TimeSlot, index: Int, lastInPastDay: Bool)
    {
        self.currentIndex = index
        
        let isRunning = timeSlot.endTime == nil
        let interval = Int(timeSlot.duration)
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        let categoryColor = timeSlot.category.color
        
        //Updates each one of the cell's components
        self.layoutLine(withColor: categoryColor, hours: hours, minutes: minutes, isRunning: isRunning, lastInPastDay: lastInPastDay)
        self.layoutElapsedTimeLabel(withColor: categoryColor, hours: hours, minutes: minutes)
        self.layoutDescriptionLabel(withTimeSlot: timeSlot, category: timeSlot.category, lastInPastDay: lastInPastDay)
        self.layoutCategoryIcon(withImageName: timeSlot.category.icon, color: categoryColor)
    }
    
    /// Updates the icon that indicates the slot's category
    private func layoutCategoryIcon(withImageName name: String, color: UIColor)
    {
        self.categoryIcon.backgroundColor = color
        self.categoryIcon.layer.cornerRadius = 16
        self.categoryIcon.image = UIImage(named: name)
    }
    
    /// Updates the label that displays the description and starting time of the slot
    private func layoutDescriptionLabel(withTimeSlot timeSlot: TimeSlot, category: Category, lastInPastDay: Bool)
    {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let dateString = formatter.string(from: timeSlot.startTime)
        let endString = lastInPastDay ? " - " + formatter.string(from: timeSlot.endTime!) : ""
        let categoryText = category == .unknown ? "" : category.rawValue.capitalized
        
        let description = "\(categoryText) \(dateString)" + endString
        let nonBoldRange = NSMakeRange(categoryText.characters.count, dateString.characters.count + endString.characters.count + 1)
        let attributedText = description.getBoldStringWithNonBoldText(nonBoldRange)
        
        slotDescription?.attributedText = attributedText
    }
    
    /// Updates the label that shows how long the slot lasted
    private func layoutElapsedTimeLabel(withColor color: UIColor, hours: Int, minutes: Int)
    {
        self.elapsedTime.textColor = color
        self.elapsedTime.text = hours > 0 ? String(format: hourMask, hours, minutes) : String(format: minuteMask, minutes)
    }
    
    /// Updates the line that displays shows how long the TimeSlot lasted
    private func layoutLine(withColor color: UIColor, hours: Int, minutes: Int, isRunning: Bool)
    {
        let newHeight = CGFloat(Constants.minLineSize * (1 + (minutes / 15) + (hours * 4)))
        self.lineHeightConstraint.constant = newHeight
        
        self.lineView.backgroundColor = color
        self.lineView.layoutIfNeeded()
        
        self.indicatorDot.backgroundColor = color
        self.indicatorDot.isHidden = !isRunning
        self.indicatorDot.layoutIfNeeded()
    }
    
    private func layoutLine(withColor color: UIColor, hours: Int, minutes: Int, isRunning: Bool, lastInPastDay: Bool)
    {
        let newHeight = CGFloat(Constants.minLineSize * (1 + (minutes / 15) + (hours * 4)))
        self.lineHeightConstraint.constant = newHeight
        
        self.lineView.backgroundColor = color
        
        //Fade the line if it is the last TimeSlot of a past day
        if lastInPastDay
        {
            let bottomFadeStartColor = UIColor.white.withAlphaComponent(1.0) //1.0
            let bottomFadeEndColor = UIColor.white.withAlphaComponent(0.0) //0.0
            let bottomFadeOverlay = self.fadeOverlay(startColor: bottomFadeStartColor, endColor: bottomFadeEndColor)
            let fadeView = AutoResizingLayerView(layer: bottomFadeOverlay)
            self.lineView.addSubview(fadeView)
            fadeView.snp.makeConstraints { make in
                make.bottom.equalTo(self.lineView.snp.bottom)
                make.left.equalTo(self.lineView.snp.left)
                make.right.equalTo(self.lineView.snp.right)
                make.height.equalTo(100)
            }
        }
        
        self.lineView.layoutIfNeeded()
        
        self.indicatorDot.backgroundColor = color
        self.indicatorDot.isHidden = !isRunning
        self.indicatorDot.layoutIfNeeded()
    }
    
    /// Configure the fade overlay
    private func fadeOverlay(startColor: UIColor, endColor: UIColor) -> CAGradientLayer
    {
        let fadeOverlay = CAGradientLayer()
        fadeOverlay.colors = [startColor.cgColor, endColor.cgColor]
        fadeOverlay.locations = [0.1]
        fadeOverlay.startPoint = CGPoint(x: 0.0, y: 1.0)
        fadeOverlay.endPoint = CGPoint(x: 0.0, y: 0.0)
        return fadeOverlay
    }
}
