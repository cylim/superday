import UIKit
import RxSwift
import QuartzCore
import CoreGraphics
import SnapKit

class AddTimeSlotView : UIView
{
    //MARK: Fields
    private let isAddingVariable = Variable(false)
    private var disposeBag : DisposeBag? = DisposeBag()
    
    @IBOutlet private weak var blur : UIView!
    @IBOutlet private weak var addButton : UIButton!
    {
        didSet
        {
            addButton.snp.makeConstraints { (make) in
                make.right.bottom.greaterThanOrEqualToSuperview().offset(-16)
            }
        }
    }
    @IBOutlet private weak var foodButton : UIButton!
    @IBOutlet private weak var workButton : UIButton!
    @IBOutlet private weak var leisureButton : UIButton!
    @IBOutlet private weak var friendsButton : UIButton!
    @IBOutlet private weak var commuteButton : UIButton!

    //MARK: Properties
    var isAdding : Bool
    {
        get { return self.isAddingVariable.value }
        set(value) { self.isAddingVariable.value = value }
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
    
    private lazy var constraintsArray =
    {
        return [
            [0, -110],
            [-54, -94],
            [-94, -54],
            [-110, 0],
            [-94, 54],
            [-54, 94],
            [0, 110],
            [54, 94],
            [94, 54],
            [110, 0],
            [94, -54],
            [54, -94]
        ]
    }()
    
    //MARK: Lifecycle methods
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        
        let cornerRadius = CGFloat(25)
        
        self.buttons.values.forEach
        { (button) in
            button.layer.cornerRadius = cornerRadius
            button.isHidden = true
            button.snp.remakeConstraints(self.constraintsToAddButton)
        }
        self.addButton.layer.cornerRadius = cornerRadius
        
        //Adds some blur to the background of the buttons
        self.blur.frame = bounds;
        let layer = CAGradientLayer()
        layer.frame = self.blur.bounds
        layer.colors = [ Color.white.withAlphaComponent(0).cgColor, Color.white.cgColor]
        layer.locations = [0.0, 1.0]
        self.blur.layer.addSublayer(layer)
        self.blur.alpha = 0
        
        //Bindings
        self.categoryObservable
            .subscribe(onNext: onNewCategory)
            .addDisposableTo(disposeBag!)
        
        self.addButton.rx.tap
            .subscribe(onNext: onAddButtonTapped)
            .addDisposableTo(disposeBag!)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool
    {
        for subview in self.subviews
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
        guard self.isAdding == true else { return }
        
        self.isAdding = false
        self.animateButtons(isAdding: false)
    }
    
    private func onNewCategory(category: Category)
    {
        self.isAdding = false
        self.animateButtons(isAdding: false, category: category)
    }
    
    private func onAddButtonTapped()
    {
        self.isAdding = !self.isAdding
//        self.animateButtons(isAdding: self.isAdding)
        self.animating(for: self.isAdding)
    }
    
    private func animating(for isOpened: Bool, category: Category = .unknown)
    {
        // Add Button animation
        let degrees:Double = (isOpened ? 45 : 0)
        UIView.animate(withDuration: 0.192, delay: 0, options: .curveEaseOut, animations:
        {
            // TODO: Suggestion for turn the addButton to gray color, or reduce alpha
            self.addButton.transform = CGAffineTransform(rotationAngle: CGFloat(degrees * (Double.pi / 180.0)))
        })
        
        // Blur View animation
        let overlayDuration = (isOpened ? 0.09 : 0.225)
        let alpha = CGFloat(isOpened ? 1.0 : 0.0)
        UIView.animate(withDuration: overlayDuration)
        {
            self.blur.alpha = alpha
        }
        
        // Categories Wheel Open/Close Animation
        let delay = (isOpened ? 0.04 : 0.02)
        self.categoriesAnimation(with: delay)
    }
    
    func categoriesAnimation(with delay: Double)
    {
        var timerDelay:Double = 0
        
        let scale = CGFloat(isAdding ? 1 : 0.3)
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        
        var count = 0
        self.buttons.values.forEach
            { (button) in
                button.isHidden = false
                
                self.startCategoriesAnimation(for: button, transform: transform, delay: timerDelay, constraints: constraintsArray[count])
                
                count += 1
                timerDelay += delay
        }
    }
    
    func startCategoriesAnimation(for button:UIButton, transform: CGAffineTransform, delay: Double, constraints:[Int] )
    {
        button.snp.remakeConstraints
            { (make) in
                self.isAdding
                    ? self.constraintsFromAddButton(make, constraints: constraints)
                    : self.constraintsToAddButton(make)
        }
        
        UIView.animate(withDuration: 0.225, delay: delay, options: .curveEaseInOut , animations:
        {
                self.layoutIfNeeded()
        },
        completion:
        { _ in
            if !self.isAdding
            {
                button.isHidden = true
            }
        })
    }
    
    func constraintsFromAddButton(_ make:ConstraintMaker, constraints: [Int]){
        make.centerX.equalTo(self.addButton.snp.centerX).offset(constraints[0]).priority(1000)
        make.centerY.equalTo(self.addButton.snp.centerY).offset(constraints[1]).priority(1000)
    }
    
    func constraintsToAddButton(_ make: ConstraintMaker)
    {
        make.center.equalTo(self.addButton.snp.center).priority(1000)
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
            self.animateCategoryButton(button)
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
                    //button.alpha = alpha
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
