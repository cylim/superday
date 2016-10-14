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
    private let animationDuration = 0.08
    
    private var disposeBag : DisposeBag? = DisposeBag()
    private var gestureRecognizer : UIGestureRecognizer!
    private lazy var viewModel : MainViewModel =
    {
        return MainViewModel(persistencyService: self.persistencyService, metricsService: self.metricsService)
    }()
    
    private var pagerViewController : PagerViewController { return self.childViewControllers.last as! PagerViewController }
    
    //Dependencies
    private var metricsService : MetricsService!
    private var settingsService : SettingsService!
    private var locationService : LocationService!
    private var editStateService : EditStateService!
    private var persistencyService : PersistencyService!
    
    private var addButton : AddTimeSlotView!
    private var launchAnim : LaunchAnimationView!
    private var editButtons : [UIImageView]? = nil
    
    @IBOutlet private weak var overlay : UIView!
    @IBOutlet private weak var icon : UIImageView!
    @IBOutlet private weak var logButton : UIButton!
    @IBOutlet private weak var titleLabel : UILabel!
    @IBOutlet private weak var debugView : DebugView!
    @IBOutlet private weak var calendarLabel : UIButton!
    
    func inject(_ locationService: LocationService, _ metricsService: MetricsService, _ persistencyService: PersistencyService, _ settingsService: SettingsService, _ editStateService: EditStateService) -> MainViewController
    {
        self.metricsService = metricsService
        self.locationService = locationService
        self.settingsService = settingsService
        self.editStateService = editStateService
        self.persistencyService = persistencyService
        
        return self
    }
    
    // MARK: UIViewController lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Inject PagerViewController's dependencies
        self.pagerViewController.inject(metricsService, settingsService, persistencyService, editStateService)
        
        //Debug screen
        self.debugView.isHidden = true
        
        //Launch animation
        self.launchAnim = LaunchAnimationView(frame: view.frame)
        self.view.addSubview(launchAnim)
        
        //Add button
        self.addButton = (Bundle.main.loadNibNamed("AddTimeSlotView", owner: self, options: nil)?.first) as? AddTimeSlotView
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.calendarLabel.setTitle(viewModel.calendarDay, for: .normal)
        
        //Refresh Dispose bag, if needed
        self.disposeBag = self.disposeBag ?? DisposeBag()
        
        self.gestureRecognizer = ClosureGestureRecognizer(withClosure: { self.editStateService.isEditing = false })
        
        //DEBUG SCREEN
        self.locationService
            .locationObservable
            .subscribe(onNext: self.debugView.onNewLocation)
            .addDisposableTo(disposeBag!)
        
        //Edit state
        self.editStateService
            .isEditingObservable
            .subscribe(onNext: self.onEditChanged)
            .addDisposableTo(disposeBag!)
        
        self.editStateService
            .beganEditingObservable
            .subscribe(onNext: self.onEditBegan)
            .addDisposableTo(disposeBag!)
        
        //Category creation
        self.addButton
            .categoryObservable
            .subscribe(onNext: self.viewModel.addNewSlot)
            .addDisposableTo(disposeBag!)
        
        //Date updates for title label
        self.pagerViewController
            .dateObservable
            .subscribe(onNext: self.onDateChanged)
            .addDisposableTo(disposeBag!)
        
        self.overlay.addGestureRecognizer(self.gestureRecognizer)
        
        //Small delay to give launch screen time to fade away
        Timer.schedule(withDelay: 0.1) { _ in
            self.launchAnim?.animate(onCompleted:
            {
                self.launchAnim!.removeFromSuperview()
                self.launchAnim = nil
                
                //Add button must be added like this due to .xib/.storyboard restrictions
                self.view.insertSubview(self.addButton, belowSubview: self.overlay!)
                self.addButton.snp.makeConstraints { make in
                    make.height.equalTo(320)
                    make.left.equalTo(self.view.snp.left)
                    make.width.equalTo(self.view.snp.width)
                    make.bottom.equalTo(self.view.snp.bottom)
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        self.disposeBag = nil
        self.overlay.removeGestureRecognizer(self.gestureRecognizer)
        super.viewWillDisappear(animated)
    }
    
    // MARK: Actions
    @IBAction func onCalendarTouchUpInside()
    {
        let today = Date().ignoreTimeComponents()
        
        guard viewModel.currentDate.ignoreTimeComponents() != today else { return }
        
        self.pagerViewController.setViewControllers(
            [ TimelineViewController(date: today,
                                     metricsService: metricsService,
                                     editStateService: editStateService,
                                     persistencyService: persistencyService) ],
            direction: .forward,
            animated: true,
            completion: nil)
        
        self.onDateChanged(date: today)
    }
    
    @IBAction func onSendLogButtonTouchUpInside()
    {
        guard MFMailComposeViewController.canSendMail() else
        {
            return self.showAlert(withTitle: "Something went wrong :(", message: "You need to set up an email account before sending emails.")
        }
        
        guard let baseURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else
        {
            return self.showAlert(withTitle: "Something went wrong :(", message: "We are unable to find the log file.")
        }
        
        let fileURL = baseURL.appendingPathComponent("swiftybeaver.log", isDirectory: false)
        
        guard let fileData = try? Data(contentsOf: fileURL) else
        {
            return self.showAlert(withTitle: "Something went wrong :(", message: "We are unable to find the log file.")
        }
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setSubject("Superday tracking log")
        mailComposer.setMessageBody("The log is attached.", isHTML: false)
        mailComposer.setToRecipients(["paul@toggl.com", "william@toggl.com"])
        mailComposer.addAttachmentData(fileData, mimeType: "text/plain", fileName: "superday.log")
        
        self.present(mailComposer, animated: true, completion: nil)
    }
    
    @IBAction func onDebugButtonTouchUpInside()
    {
        self.debugView.isHidden = !self.debugView.isHidden
    }
    
    // MARK: MFMailComposeViewControllerDelegate implementation
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Methods
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
        //Grey out views
        UIView.animate(withDuration: animationDuration) { self.overlay.isHidden = !isEditing }
        
        //Disable buttons
        self.addButton.isUserInteractionEnabled = !isEditing
        self.logButton.isUserInteractionEnabled = !isEditing
        self.calendarLabel.isUserInteractionEnabled = !isEditing
        
        //Close add menu
        self.addButton.close()
        
        guard let viewsToRemove = self.editButtons else { return }
        
        var animationDelay = Double(viewsToRemove.count - 1) * animationDuration
        viewsToRemove.forEach { v in
            
            UIView.animate(withDuration: animationDuration,
                           delay: animationDelay,
                           options: [ .curveEaseInOut ],
                           animations: { v.alpha = 0 },
                           completion: { _ in v.removeFromSuperview()} )
            
            animationDelay -= animationDuration
        }
        
        self.editButtons = nil
    }
    
    private func onEditBegan(point: CGPoint, timeSlot: TimeSlot)
    {
        guard point.x != 0 && point.y != 0 else { return }
        
        self.editButtons = Constants.categories
            .filter { c in c != .unknown && c != timeSlot.category }
            .map { category in return mapCategoryIntoView(category, timeSlot) }
        
        let firstImageView = UIImageView(image: UIImage(named: Category.unknown.icon))
        firstImageView.backgroundColor = timeSlot.category.color
        firstImageView.layer.cornerRadius = 16
        firstImageView.contentMode = .center
        
        self.view.addSubview(firstImageView)
        firstImageView.snp.makeConstraints { make in
            make.width.equalTo(32)
            make.height.equalTo(32)
            make.top.equalTo(point.y - 24)
            make.left.equalTo(point.x - 32)
        }
        
        var animationDelay = 0.0
        var previousImageView = firstImageView
        for imageView in self.editButtons!
        {
            self.view.addSubview(imageView)
            
            let previousSnp = previousImageView.snp
            
            imageView.snp.makeConstraints { make in
                
                make.width.width.equalTo(44)
                make.width.height.equalTo(44)
                make.centerY.equalTo(previousSnp.centerY)
                make.left.equalTo(previousSnp.right).offset(5)
            }
            
            UIView.animate(withDuration: animationDuration,
                           delay: animationDelay,
                           options: [ .curveEaseInOut ],
                           animations: { imageView.alpha = 1 })
            
            animationDelay += animationDuration
            previousImageView = imageView
        }
        
        self.editButtons!.insert(firstImageView, at: 0)
    }
    
    private func mapCategoryIntoView(_ category: Category, _ timeSlot: TimeSlot) -> UIImageView
    {
        let image = UIImage(named: category.icon)
        let imageView = UIImageView(image: image)
        let gestureRecognizer = ClosureGestureRecognizer(withClosure:
            {
                self.viewModel.updateTimeSlot(timeSlot, withCategory: category)
                
                self.editStateService.isEditing = false
        })
        
        imageView.alpha = 0
        imageView.contentMode = .center
        imageView.layer.cornerRadius = 22
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = category.color
        imageView.addGestureRecognizer(gestureRecognizer)
        
        return imageView
    }
    
    func showAlert(withTitle title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
