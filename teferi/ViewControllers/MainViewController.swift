import UIKit
import RxSwift
import MessageUI
import CoreMotion
import CoreGraphics
import QuartzCore
import CoreLocation
import SnapKit

class MainViewController : UIViewController, MFMailComposeViewControllerDelegate
{
    // MARK: Fields
    private var isFirstUse = false
    private let animationDuration = 0.08
    
    private var viewModel : MainViewModel!
    private var viewModelLocator : ViewModelLocator!
    private let disposeBag : DisposeBag = DisposeBag()
    private var gestureRecognizer : UIGestureRecognizer!
    
    private var pagerViewController : PagerViewController { return self.childViewControllers.firstOfType() }
    
    private var calendarViewController : CalendarViewController { return self.childViewControllers.firstOfType() }
    
    //Dependencies
    private var editView : EditTimeSlotView!
    private var addButton : AddTimeSlotView!
    private var permissionView : PermissionView?
    private var launchAnim : LaunchAnimationView!
    
    @IBOutlet private weak var icon : UIImageView!
    @IBOutlet private weak var titleLabel : UILabel!
    @IBOutlet private weak var calendarButton : UIButton!
    @IBOutlet private weak var contactButton: UIButton!
    
    func inject(viewModelLocator: ViewModelLocator) -> MainViewController
    {
        self.viewModelLocator = viewModelLocator
        self.viewModel = viewModelLocator.getMainViewModel(forViewController: self)
        return self
    }
    
    // MARK: UIViewController lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Injecting child ViewController's dependencies
        self.pagerViewController.inject(viewModelLocator: viewModelLocator)
        self.calendarViewController.inject(viewModel: viewModelLocator.getCalendarViewModel())
        
        //Edit View
        self.editView = EditTimeSlotView(editEndedCallback: self.viewModel.updateTimeSlot)
        self.view.insertSubview(self.editView, belowSubview: self.calendarViewController.view.superview!)
        self.editView.constrainEdges(to: self.view)
        
        //Add button
        self.addButton = (Bundle.main.loadNibNamed("AddTimeSlotView", owner: self, options: nil)?.first) as? AddTimeSlotView
        self.view.insertSubview(self.addButton, belowSubview: self.editView)
        self.addButton.snp.makeConstraints { make in
            make.height.equalTo(320)
            make.left.right.bottom.equalTo(self.view)
        }
        
        //Add fade overlay at bottom of timeline
        let bottomFadeOverlay = self.fadeOverlay(startColor: Color.white,
                                                 endColor: Color.white.withAlphaComponent(0.0))
        let fadeView = AutoResizingLayerView(layer: bottomFadeOverlay)
        fadeView.isUserInteractionEnabled = false
        self.view.insertSubview(fadeView, aboveSubview: self.addButton)
        fadeView.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(self.view)
            make.height.equalTo(100)
        }
        
        if self.isFirstUse
        {
            //Sets the first TimeSlot's category to leisure
            self.viewModel.addNewSlot(withCategory: .leisure, isFirstTimeSlot: true)
        }
        else
        {
            self.launchAnim = LaunchAnimationView(frame: view.frame)
            self.view.addSubview(launchAnim)
        }
        
        self.createBindings()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.startLaunchAnimation()
        
        self.calendarButton.setTitle(viewModel.calendarDay, for: .normal)
    }
    
     private func createBindings()
     {
        self.gestureRecognizer = ClosureGestureRecognizer(withClosure: { self.viewModel.notifyEditingEnded() })
        
        //Edit state
        self.viewModel
            .isEditingObservable
            .subscribe(onNext: self.onEditChanged)
            .addDisposableTo(self.disposeBag)
        
        self.viewModel
            .beganEditingObservable
            .subscribe(onNext: self.editView.onEditBegan)
            .addDisposableTo(self.disposeBag)
        
        //Category creation
        self.addButton
            .categoryObservable
            .subscribe(onNext: self.viewModel.addNewSlot)
            .addDisposableTo(self.disposeBag)
        
        //Date updates for title label
        self.viewModel
            .dateObservable
            .subscribe(onNext: self.onDateChanged)
            .addDisposableTo(self.disposeBag)
        
        self.viewModel
            .overlayStateObservable
            .subscribe(onNext: self.onOverlayStateChanged)
            .addDisposableTo(self.disposeBag)
        
        self.editView.addGestureRecognizer(self.gestureRecognizer)
        
        //Add button must be added like this due to .xib/.storyboard restrictions
        self.view.insertSubview(self.addButton, belowSubview: self.editView)
        self.addButton.snp.makeConstraints { make in
            make.height.equalTo(320)
            make.left.right.bottom.equalTo(self.view)
        }
    }
    
    // MARK: Actions
    @IBAction func onCalendarTouchUpInside()
    {
        if self.calendarViewController.isVisible
        {
            self.calendarViewController.hide()
        }
        else
        {
            self.calendarViewController.show()
        }
    }
    
    // MARK: Calendar Actions
    @IBAction func onContactTouchUpInside()
    {
        self.viewModel.composeFeedback
        {
            self.pagerViewController.feedbackUIClosing = true
        }
    }
    
    // MARK: Methods
    func setIsFirstUse()
    {
        self.isFirstUse = true
    }
    
    private func startLaunchAnimation()
    {
        guard self.launchAnim != nil else { return }
        
        //Small delay to give launch screen time to fade away
        Timer.schedule(withDelay: 0.1) { _ in
            self.launchAnim?.animate(onCompleted:
            {
                self.launchAnim!.removeFromSuperview()
                self.launchAnim = nil
            })
        }
    }
    
    private func onOverlayStateChanged(shouldShow: Bool)
    {
        if shouldShow
        {
            guard permissionView == nil else { return }
            
            let isFirstTimeUser = !self.viewModel.canIgnoreLocationPermission
            let view = Bundle.main.loadNibNamed("PermissionView", owner: self, options: nil)!.first as! PermissionView!
            
            self.permissionView = view!.inject(self.view.frame, { self.viewModel.setLastAskedForLocationPermission() }, isFirstTimeUser: isFirstTimeUser)
            
            if self.launchAnim != nil
            {
                self.view.insertSubview(self.permissionView!, belowSubview: self.launchAnim)
            }
            else
            {
                self.view.addSubview(self.permissionView!)
            }
        }
        else
        {
            guard let view = permissionView else { return }
            
            view.fadeView()
            self.permissionView = nil
            self.viewModel.setAllowedLocationPermission()
        }
    }
    
    private func onDateChanged(date: Date)
    {
        self.titleLabel.text = viewModel.title
        
        let today = self.viewModel.currentDate
        let isToday = today.ignoreTimeComponents() == date.ignoreTimeComponents()
        let alpha = CGFloat(isToday ? 1 : 0)
        
        UIView.animate(withDuration: 0.3)
        {
            self.addButton.alpha = alpha
        }
        
        self.addButton.close()
        self.addButton.isUserInteractionEnabled = isToday
        
        self.updateSelectedDate(date: date)
    }
    
    private func onEditChanged(_ isEditing: Bool)
    {
        //Close add menu
        self.addButton.close()
        
        //Grey out views
        self.editView.isEditing = isEditing
    }
    
    //Configure overlay
    private func fadeOverlay(startColor: UIColor, endColor: UIColor) -> CAGradientLayer
    {
        let fadeOverlay = CAGradientLayer()
        fadeOverlay.colors = [startColor.cgColor, endColor.cgColor]
        fadeOverlay.locations = [0.1]
        fadeOverlay.startPoint = CGPoint(x: 0.0, y: 1.0)
        fadeOverlay.endPoint = CGPoint(x: 0.0, y: 0.0)
        return fadeOverlay
    }
    
    func updateSelectedDate(date: Date)
    {
        self.calendarViewController.hide()
    }
    
    private func onCalendarClose(date: Date)
    {
        self.calendarViewController.hide()
    }
}
