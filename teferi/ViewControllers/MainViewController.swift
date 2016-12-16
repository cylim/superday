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
    
    private let disposeBag : DisposeBag = DisposeBag()
    private var gestureRecognizer : UIGestureRecognizer!
    private lazy var viewModel : MainViewModel =
    {
        return MainViewModel(metricsService: self.metricsService,
                             feedbackService: self.feedbackService,
                             settingsService: self.settingsService,
                             timeSlotService: self.timeSlotService,
                             locationService: self.locationService,
                             editStateService: self.editStateService,
                             smartGuessService: self.smartGuessService)
    }()
    
    private var pagerViewController : PagerViewController { return self.childViewControllers.last as! PagerViewController }
    
    //Dependencies
    private var metricsService : MetricsService!
    private var feedbackService: FeedbackService!
    private var appStateService : AppStateService!
    private var locationService : LocationService!
    private var settingsService : SettingsService!
    private var timeSlotService : TimeSlotService!
    private var editStateService : EditStateService!
    private var smartGuessService: SmartGuessService!
    
    private var editView : EditTimeSlotView!
    private var addButton : AddTimeSlotView!
    private var permissionView : PermissionView?
    private var launchAnim : LaunchAnimationView!
    
    @IBOutlet private weak var icon : UIImageView!
    @IBOutlet private weak var titleLabel : UILabel!
    @IBOutlet private weak var calendarButton : UIButton!
    @IBOutlet private weak var contactButton: UIButton!
    
    func inject(_ metricsService: MetricsService,
                _ appStateService: AppStateService,
                _ locationService: LocationService,
                _ settingsService: SettingsService,
                _ timeSlotService: TimeSlotService,
                _ editStateService: EditStateService,
                _ feedbackService: FeedbackService,
                _ smartGuessService: SmartGuessService) -> MainViewController
    {
        self.metricsService = metricsService
        self.feedbackService = feedbackService
        self.appStateService = appStateService
        self.locationService = locationService
        self.settingsService = settingsService
        self.timeSlotService = timeSlotService
        self.editStateService = editStateService
        self.smartGuessService = smartGuessService
        
        return self
    }
    
    // MARK: UIViewController lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Inject PagerViewController's dependencies
        self.pagerViewController.inject(self.metricsService,
                                        self.appStateService,
                                        self.settingsService,
                                        self.timeSlotService,
                                        self.editStateService)        
        
        //Add fade overlay at bottom of timeline
        let bottomFadeStartColor = Color.white.withAlphaComponent(1.0)
        let bottomFadeEndColor = Color.white.withAlphaComponent(0.0)
        let bottomFadeOverlay = self.fadeOverlay(startColor: bottomFadeStartColor, endColor: bottomFadeEndColor)
        let fadeView = AutoResizingLayerView(layer: bottomFadeOverlay)
        fadeView.isUserInteractionEnabled = false
        self.view.addSubview(fadeView)
        fadeView.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(self.view)
            make.height.equalTo(100)
        }
        
        //Add button
        self.addButton = (Bundle.main.loadNibNamed("AddTimeSlotView", owner: self, options: nil)?.first) as? AddTimeSlotView
        
        //Edit View
        self.editView = EditTimeSlotView(editEndedCallback: self.viewModel.updateTimeSlot)
        self.view.addSubview(self.editView)
        self.editView.constrainEdges(to: self.view)
        
        if self.isFirstUse
        {
            //Sets the first TimeSlot's category to leisure
            let timeSlot = TimeSlot(withStartTime: Date(), category: .leisure, categoryWasSetByUser: false)
            self.timeSlotService.add(timeSlot: timeSlot)
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
        self.gestureRecognizer = ClosureGestureRecognizer(withClosure: { self.editStateService.notifyEditingEnded() })
        
        //Edit state
        self.editStateService
            .isEditingObservable
            .subscribe(onNext: self.onEditChanged)
            .addDisposableTo(self.disposeBag)
        
        self.editStateService
            .beganEditingObservable
            .subscribe(onNext: self.editView.onEditBegan)
            .addDisposableTo(self.disposeBag)
        
        //Category creation
        self.addButton
            .categoryObservable
            .subscribe(onNext: self.viewModel.addNewSlot)
            .addDisposableTo(self.disposeBag)
        
        //Date updates for title label
        self.pagerViewController
            .dateObservable
            .subscribe(onNext: self.onDateChanged)
            .addDisposableTo(self.disposeBag)
        
        self.editView.addGestureRecognizer(self.gestureRecognizer)
        
        self.appStateService
            .appStateObservable
            .subscribe(onNext: self.onAppStateChanged)
            .addDisposableTo(self.disposeBag)
        
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
        let today = Date().ignoreTimeComponents()
        
        guard self.viewModel.currentDate.ignoreTimeComponents() != today else { return }
        
        self.pagerViewController.setViewControllers(
            [ TimelineViewController(date: today,
                                     metricsService: self.metricsService,
                                     appStateService: self.appStateService,
                                     timeSlotService: self.timeSlotService,
                                     editStateService: self.editStateService) ],
            direction: .forward,
            animated: true,
            completion: nil)
        
        self.onDateChanged(date: today)
    }
    
    @IBAction func onContactTouchUpInside()
    {
        self.feedbackService.composeFeedback(parentViewController: self) {
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
    
    private func onAppStateChanged(appState: AppState)
    {
        if appState == .active
        {
            if self.viewModel.shouldShowLocationPermissionOverlay
            {
                guard permissionView == nil else { return }
                
                let isFirstTimeUser = !self.settingsService.canIgnoreLocationPermission
                let view = Bundle.main.loadNibNamed("PermissionView", owner: self, options: nil)!.first as! PermissionView!
                
                self.permissionView = view!.inject(self.view.frame, self.settingsService, isFirstTimeUser: isFirstTimeUser)
                
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
                self.settingsService.setAllowedLocationPermission()
            }
        }
    }
    
    private func onDateChanged(date: Date)
    {
        self.viewModel.currentDate = date
        self.titleLabel.text = viewModel.title
        
        let today = Date().ignoreTimeComponents()
        let isToday = today == date.ignoreTimeComponents()
        let alpha = CGFloat(isToday ? 1 : 0)
        
        UIView.animate(withDuration: 0.3)
        {
            self.addButton.alpha = alpha
        }
        
        self.addButton.close()
        self.addButton.isUserInteractionEnabled = isToday
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
}
