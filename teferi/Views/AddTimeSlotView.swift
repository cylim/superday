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
    
    //MARK: Properties
    var isAdding : Bool
    {
        get { return self.isAddingVariable.value }
        set(value) { self.isAddingVariable.value = value }
    }
    
    lazy var buttons : [Category:UIButton] =
    {
        var btns: [Category:UIButton] = [:]
        var categories = Constants.categories.filter { c in c != .unknown}
        categories.forEach { c in btns[c] = self.toButton(from: c)}
        return  btns
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
    
    func toButton(from category: Category) -> UIButton
    {
        let cornerRadius = CGFloat(25)
        
        let button = UIButton(type: .custom)
        self.insertSubview(button, belowSubview: self.addButton)
        
        button.snp.remakeConstraints(self.constraintsToAddButton)
        button.layer.cornerRadius = cornerRadius
        
        button.backgroundColor = category.color
        button.setImage(UIImage(asset: category.icon), for: .normal)
        
        button.isHidden = true
        
        return button
    }
    
    //MARK: Methods
    func close()
    {
        guard self.isAdding == true else { return }
        
        self.isAdding = false
        self.animating(isAdding: false)
    }
    
    private func onNewCategory(category: Category)
    {
        self.isAdding = false
        self.animating(isAdding: false, category: category)
    }
    
    private func onAddButtonTapped()
    {
        self.isAdding = !self.isAdding
        self.animating(isAdding: self.isAdding)
    }
    
    private func animating(isAdding: Bool, category: Category = .unknown)
    {
        let degrees:Double = (isAdding ? 45 : 0)
        let overlayDuration = (isAdding ? 0.09 : 0.225)
        let alpha = CGFloat(isAdding ? 1.0 : 0.0)
        let delay = (isAdding ? 0.04 : 0.02)
        
        // Add Button animation
        UIView.animate(withDuration: 0.192, delay: 0, options: .curveEaseOut, animations:
        {
            // TODO: Suggestion for turn the addButton to gray color, or reduce alpha
            self.addButton.transform = CGAffineTransform(rotationAngle: CGFloat(degrees * (Double.pi / 180.0)))
        })
        
        // Blur View animation
        
        UIView.animate(withDuration: overlayDuration)
        {
            self.blur.alpha = alpha
        }
        
        // Categories Wheel Open/Close Animation
        self.startCategoriesAnimation(with: delay)
    }
    
    func startCategoriesAnimation(with delay: Double)
    {
        var timerDelay:Double = 0
        var count = 0
        
        self.buttons.values.forEach
            { (button) in
                button.isHidden = false
                
                self.categoryAnimation(for: button, transform: transform, delay: timerDelay, constraints: constraintsArray[count])
                
                count += 1
                timerDelay += delay
        }
    }
    
    func categoryAnimation(for button:UIButton, transform: CGAffineTransform, delay: Double, constraints:[Int] )
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
        make.width.height.greaterThanOrEqualTo(50)
        make.centerX.equalTo(self.addButton.snp.centerX).offset(constraints[0]).priority(1000)
        make.centerY.equalTo(self.addButton.snp.centerY).offset(constraints[1]).priority(1000)
    }
    
    func constraintsToAddButton(_ make: ConstraintMaker)
    {
        make.width.height.greaterThanOrEqualTo(50)
        make.center.equalTo(self.addButton.snp.center).priority(1000)
    }
}
