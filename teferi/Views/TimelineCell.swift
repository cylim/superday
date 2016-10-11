import UIKit
import CoreGraphics
import SnapKit
import RxSwift

///Cell that represents a TimeSlot in the timeline
class TimelineCell : UITableViewCell
{
    // MARK: Fields
    private var currentIndex = 0
    private let animationDuration = 0.08
    private let hourMask = "%02d h %02d min"
    private let minuteMask = "%02d min"
    private lazy var lineHeightConstraint : NSLayoutConstraint =
    {
        return NSLayoutConstraint(item: self.lineView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(Constants.minLineSize))
    }()
    
    private var editButtons : [UIImageView]? = nil
    
    @IBOutlet weak private var lineView : UIView?
    @IBOutlet weak private var elapsedTime : UILabel?
    @IBOutlet weak private var categoryButton : UIButton?
    @IBOutlet weak private var slotDescription : UILabel?
    @IBOutlet weak private var categoryIcon : UIImageView?
    @IBOutlet private weak var indicatorDot: UIView?
    
    //MARK: Properties
    private(set) var isSubscribedToClickObservable = false
    var editClickObservable : Observable<Int>
    {
        self.isSubscribedToClickObservable = true
        return categoryButton!.rx.tap.map { return self.currentIndex }.asObservable()
    }
    
    var onCategoryChange : ((Int, Category) -> Void)?
    
    // MARK: Methods
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.lineView?.addConstraint(lineHeightConstraint)
    }
    
    /**
     Binds the current TimeSlot in order to change the UI accordingly.
     
     - Parameter timeSlot: TimeSlot that will be bound.
     */
    func bind(toTimeSlot timeSlot: TimeSlot, shouldFade: Bool, index: Int, isEditingCategory: Bool)
    {
        self.currentIndex = index
        
        let isRunning = timeSlot.endTime == nil
        let interval = Int(timeSlot.duration)
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        let alpha = shouldFade ? Constants.editingAlpha : 1
        let categoryColor = timeSlot.category.color
        
        //Updates each one of the cell's components
        self.layoutLine(withColor: categoryColor, hours: hours, minutes: minutes, alpha: alpha, isRunning: isRunning)
        self.layoutElapsedTimeLabel(withColor: categoryColor, hours: hours, minutes: minutes, alpha: alpha)
        self.layoutDescriptionLabel(withStartTime: timeSlot.startTime, category: timeSlot.category, alpha: alpha)
        self.layoutCategoryIcon(withImageName: timeSlot.category.icon, color: categoryColor, alpha: isEditingCategory ? 1 : alpha)
        
        guard isEditingCategory else
        {
            if let viewsToRemove = self.editButtons
            {
                self.editButtons = nil
                viewsToRemove.forEach { view in view.removeFromSuperview() }
            }
            
            return
        }
        
        if let viewsToRemove = self.editButtons
        {
            viewsToRemove.forEach { v in v.removeFromSuperview() }
            self.editButtons = nil
        }
        
        self.categoryIcon?.image = UIImage(named: Category.unknown.icon)
        
        self.editButtons = Constants.categories
            .filter { c in c != .unknown && c != timeSlot.category }
            .map(mapCategoryIntoView)
        
        var animationDelay = 0.0
        var previousImageView = categoryIcon!
        for imageView in editButtons!
        {
            self.addSubview(imageView)
            
            let previousSnp = previousImageView.snp
            
            imageView.snp.makeConstraints { make in makeConstraints(withMaker: make, previousSnp: previousSnp) }
            
            UIView.animate(withDuration: animationDuration, delay: animationDelay, options: [ .curveEaseInOut ], animations: { imageView.alpha = 1 })
            
            animationDelay += animationDuration
            previousImageView = imageView
        }
    }
    
    /// Updates the icon that indicates the slot's category
    private func layoutCategoryIcon(withImageName name: String, color: UIColor, alpha: CGFloat)
    {
        categoryIcon?.alpha = alpha
        categoryIcon?.backgroundColor = color
        categoryIcon?.layer.cornerRadius = 16
        categoryIcon?.image = UIImage(named: name)
    }
    
    /// Updates the label that displays the description and starting time of the slot
    private func layoutDescriptionLabel(withStartTime startTime: Date, category: Category, alpha: CGFloat)
    {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        let dateString = formatter.string(from: startTime)
        let categoryText = category == .unknown ? "" : String(describing: category)
        
        let description = "\(categoryText) \(dateString)"
        let nonBoldRange = NSMakeRange(categoryText.characters.count, dateString.characters.count)
        let attributedText = description.getBoldStringWithNonBoldText(nonBoldRange)
        
        slotDescription?.attributedText = attributedText
        slotDescription?.alpha = alpha
    }
    
    /// Updates the label that shows how long the slot lasted
    private func layoutElapsedTimeLabel(withColor color: UIColor, hours: Int, minutes: Int, alpha: CGFloat)
    {
        elapsedTime?.alpha = alpha
        elapsedTime?.textColor = color
        elapsedTime?.text = hours > 0 ? String(format: hourMask, hours, minutes) : String(format: minuteMask, minutes)
    }
    
    /// Updates the line that displays shows how long the TimeSlot lasted
    private func layoutLine(withColor color: UIColor, hours: Int, minutes: Int, alpha: CGFloat, isRunning: Bool)
    {
        let newHeight = CGFloat(Constants.minLineSize * (1 + (minutes / 15) + (hours * 4)))
        lineHeightConstraint.constant = newHeight
        
        lineView?.alpha = alpha
        lineView?.backgroundColor = color
        lineView?.layoutIfNeeded()
        
        indicatorDot?.alpha = alpha
        indicatorDot?.backgroundColor = color
        indicatorDot?.isHidden = !isRunning
        indicatorDot?.layoutIfNeeded()
    }
    
    private func mapCategoryIntoView(category: Category) -> UIImageView
    {
        let image = UIImage(named: category.icon)
        let imageView = UIImageView(image: image)
        let gestureRecognizer = ClosureGestureRecognizer(withClosure: { self.changeCategory(to: category) })
        
        imageView.alpha = 0
        imageView.contentMode = .center
        imageView.layer.cornerRadius = 22
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = category.color
        imageView.addGestureRecognizer(gestureRecognizer)
        
        return imageView
    }
    
    private func makeConstraints(withMaker make: ConstraintMaker, previousSnp: ConstraintViewDSL)
    {
        make.width.width.equalTo(44)
        make.width.height.equalTo(44)
        make.left.equalTo(previousSnp.right).offset(5)
        make.centerY.equalTo(previousSnp.centerY)
    }
    
    private func changeCategory(to category: Category)
    {
        onCategoryChange?(currentIndex, category)
    }
}
