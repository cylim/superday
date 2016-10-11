import UIKit
import RxSwift
import QuartzCore
import CoreGraphics

class AddTimeSlotView : UIView
{
    //MARK: Fields
    private let isAddingVariable = Variable(false)
    private var disposeBag : DisposeBag? = DisposeBag()
    
    @IBOutlet private weak var blur : UIView!
    @IBOutlet private weak var addButton : UIButton!
    @IBOutlet private weak var foodButton : UIButton!
    @IBOutlet private weak var workButton : UIButton!
    @IBOutlet private weak var leisureButton : UIButton!
    @IBOutlet private weak var friendsButton : UIButton!
    @IBOutlet private weak var commuteButton : UIButton!

    //MARK: Properties
    var isAdding : Bool
    {
        get { return isAddingVariable.value }
        set(value) { isAddingVariable.value = value }
    }
    
    private lazy var buttons : [Category:UIButton] =
    {
        return [
            .food : self.foodButton,
            .work : self.workButton,
            .leisure : self.leisureButton,
            .friends : self.friendsButton,
            .commute : self.commuteButton
        ]
    }()
    
    lazy var categoryObservable : Observable<Category> =
    {
        let taps = self.buttons.map
        { (category, button) in
            button.rx.tap.map { _ in return category }
        }
        return Observable.from(taps).merge()
    }()
    
    //MARK: Lifecycle methods
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        
        let cornerRadius = CGFloat(25)
        
        buttons.values.forEach
        { (button) in
            button.layer.cornerRadius = cornerRadius
            button.alpha = 0
            button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            button.isHidden = true
        }
        self.addButton.layer.cornerRadius = cornerRadius
        
        //Adds some blur to the background of the buttons
        self.blur.frame = bounds;
        let layer = CAGradientLayer()
        layer.frame = self.blur.bounds
        layer.colors = [ UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor]
        layer.locations = [0.0, 1.0]
        self.blur.layer.addSublayer(layer)
        self.blur.alpha = 0
        
        //Bindings
        self.categoryObservable
            .subscribe(onNext: onNewCategory)
            .addDisposableTo(disposeBag!)
        
        addButton.rx.tap
            .subscribe(onNext: onAddButtonTapped)
            .addDisposableTo(disposeBag!)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool
    {
        for subview in subviews
        {
            if !subview.isHidden && subview.alpha > 0 && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event)
            {
                return true
            }
        }
        
        return false
    }
    
    //MARK: Methods
    func close()
    {
        guard isAdding == true else { return }
        
        isAdding = false
        animateButtons(isAdding: false)
    }
    
    private func onNewCategory(category: Category)
    {
        isAdding = false
        animateButtons(isAdding: false, category: category)
    }
    
    private func onAddButtonTapped()
    {
        isAdding = !isAdding
        animateButtons(isAdding: isAdding)
    }
    
    private func animateButtons(isAdding: Bool, category: Category = .unknown)
    {
        let scale = CGFloat(isAdding ? 1 : 0.01)
        let alpha = CGFloat(isAdding ? 1.0 : 0.0)
        let degrees = isAdding ? 45.0 : 0.0
        let addButtonAlpha = CGFloat(isAdding ? 0.31 : 1.0)
        let options = isAdding ? UIViewAnimationOptions.curveEaseOut : UIViewAnimationOptions.curveEaseIn
        
        let categoryButtons : [UIButton]
        let delay : TimeInterval
        
        if category == .unknown
        {
            categoryButtons = self.buttons.map { $0.1 }
            delay = 0
        }
        else
        {
            let button = self.buttons[category]!
            categoryButtons = self.buttons.values.filter { (b) in b != button }
            delay = 0.4 * 0.3
            animateCategoryButton(button)
        }
        
        categoryButtons.forEach { (button) in button.isHidden = false }
        
        UIView.animate(withDuration: 0.2, delay: delay,
            options: options,
            animations:
            {
                //Category buttons
                let transform = CGAffineTransform(scaleX: scale, y: scale)
                categoryButtons.forEach { (button) in
                    button.transform = transform
                    button.alpha = alpha
                }
                
                //Add button
                self.addButton.alpha = addButtonAlpha
                self.addButton.transform = CGAffineTransform(rotationAngle: CGFloat(degrees * (Double.pi / 180.0)));
            },
            completion:
            { (_) in
                if !isAdding
                {
                    categoryButtons.forEach { (button) in button.isHidden = true }
                }
            })
        
        UIView.animate(withDuration: 0.25)
        {
            self.blur.alpha = alpha
        }
    }
    
    private func animateCategoryButton(_ button: UIButton)
    {
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: .calculationModeCubic,
            animations:
            {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4)
                {
                    button.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                }
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.6)
                {
                    button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                    button.alpha = 0
                }
            },
            completion:
            { (_) in
                button.isHidden = true
            })
    }
}
