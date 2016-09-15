import UIKit
import CoreLocation
import RxSwift
import CircleMenu
import CoreMotion

class MainViewController : UIViewController, CircleMenuDelegate
{
    // MARK: Fields
    private let menuItems : [Category] = [
        Category.Friends,
        Category.Work,
        Category.Leisure,
        Category.Commute,
        Category.Food
    ]
    
    private let viewModel : MainViewModel = MainViewModel()
    private var disposeBag : DisposeBag? = DisposeBag()
    private var pagerViewController : PagerViewController
    {
        return self.childViewControllers.last as! PagerViewController
    }
    
    private var circleMenu : CircleMenu? = nil
    @IBOutlet private weak var titleLabel : UILabel?
    
    // MARK: UIViewController lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        pagerViewController.onDateChanged = onDateChanged
        setMenuButton()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        disposeBag = nil
        super.viewWillDisappear(animated)
    }
    
    // MARK: Callbacks
    private func onDateChanged(date: NSDate)
    {
        viewModel.date = date
        titleLabel?.text = viewModel.title
    }
    
    // MARK: Methods
    private func setMenuButton()
    {
        let buttonSize = CGFloat(50)
        
        circleMenu = CircleMenu(
            frame: CGRect(x: UIScreen.mainScreen().bounds.width / 2 - buttonSize / 2, y: UIScreen.mainScreen().bounds.height - 150, width: buttonSize, height: buttonSize),
            normalIcon:"icAddBig",
            selectedIcon:"icCancelBig",
            buttonsCount: 5,
            duration: 0.5,
            distance: 90)
        circleMenu!.delegate = self
        circleMenu!.layer.cornerRadius = circleMenu!.frame.size.width / 2.0
        view.addSubview(circleMenu!)
    }
    
    //MARK: CircleMenuDelegate implementation
    func circleMenu(circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int)
    {
        let category = menuItems[atIndex]
        
        button.backgroundColor = category.color
        button.setImage(UIImage(imageLiteral: category.assetInfo.big), forState: .Normal)
        
        // set highlited image
        let highlightedImage  = UIImage(imageLiteral: category.assetInfo.big).imageWithRenderingMode(.AlwaysTemplate)
        button.setImage(highlightedImage, forState: .Highlighted)
        button.tintColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.3)
    }
    
    func circleMenu(circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int)
    {
        pagerViewController.addNewSlot(menuItems[atIndex])
    }
    
    func circleMenu(circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int)
    {
        print("button did selected: \(atIndex)")
    }
}




















