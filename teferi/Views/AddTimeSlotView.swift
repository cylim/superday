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
    
    lazy var categoryObservable : Observable<Category> =
    {
        let food = self.foodButton.rx.tap.map { _ in return Category.food }
        let work = self.workButton.rx.tap.map { _ in return Category.work }
        let leisure = self.leisureButton.rx.tap.map { _ in return Category.leisure }
        let friends = self.friendsButton.rx.tap.map { _ in return Category.friends }
        let commute = self.commuteButton.rx.tap.map { _ in return Category.commute }
        
        return Observable
                .of(food, work, leisure, friends, commute)
                .merge()
    }()
    
    //MARK: Lifecycle methods
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        
        let cornerRadius = CGFloat(25)
        
        self.addButton.layer.cornerRadius = cornerRadius
        self.foodButton.layer.cornerRadius = cornerRadius
        self.workButton.layer.cornerRadius = cornerRadius
        self.leisureButton.layer.cornerRadius = cornerRadius
        self.friendsButton.layer.cornerRadius = cornerRadius
        self.commuteButton.layer.cornerRadius = cornerRadius
        
        //Adds some blur to the background of the buttons
        let layer = CAGradientLayer()
        layer.frame = self.blur.bounds
        layer.colors = [ UIColor(r: 255, g: 255, b: 255, a: 0.0).cgColor, UIColor.white.cgColor, UIColor.white.cgColor]
        layer.locations = [0.0, 0.3, 1.0]
        self.blur.layer.addSublayer(layer)
        
        
        //Bindings
        self.categoryObservable
            .subscribe(onNext: onNewCategory)
            .addDisposableTo(disposeBag!)
        
        addButton.rx.tap
            .subscribe(onNext: onAddButtonTapped)
            .addDisposableTo(disposeBag!)
        
        self.isAddingVariable
            .asObservable()
            .subscribe(onNext: onIsAddingChanged)
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
    private func onNewCategory(category: Category)
    {
        isAdding = false
    }
    
    private func onAddButtonTapped()
    {
        isAdding = !isAdding
    }
    
    private func onIsAddingChanged(isAdding: Bool)
    {
        let scale = CGFloat(isAdding ? 1 : 0)
        let degrees = isAdding ? 45.0 : 0.0
        let addButtonAlpha = CGFloat(isAdding ? 0.31 : 1.0)
        
        UIView.animate(withDuration: 0.15)
        {
            self.blur.alpha = scale
            
            //Category buttons
            self.foodButton.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.workButton.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.leisureButton.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.friendsButton.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.commuteButton.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            //Add button
            self.addButton.alpha = addButtonAlpha
            self.addButton.transform = CGAffineTransform(rotationAngle: CGFloat(degrees * (Double.pi / 180.0)));
        }
    }
}
