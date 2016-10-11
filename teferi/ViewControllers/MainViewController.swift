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
    private var disposeBag : DisposeBag? = DisposeBag()
    private let viewModel : MainViewModel = MainViewModel(persistencyService: AppDelegate.instance.persistencyService, metricsService: AppDelegate.instance.metricsService)
    private var pagerViewController : PagerViewController { return self.childViewControllers.last as! PagerViewController }
    
    private var addButton : AddTimeSlotView!
    private var launchAnim : LaunchAnimationView?
    
    @IBOutlet private weak var icon : UIImageView!
    @IBOutlet private weak var logButton : UIButton!
    @IBOutlet private weak var titleLabel : UILabel!
    @IBOutlet private weak var debugView : DebugView!
    @IBOutlet private weak var calendarLabel : UIButton!
    
    // MARK: UIViewController lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Debug screen
        debugView.isHidden = true
        AppDelegate.instance
            .locationService
            .subscribeToLocationChanges(debugView.onNewLocation)
        
        self.addButton = (Bundle.main.loadNibNamed("AddTimeSlotView", owner: self, options: nil)?.first) as! AddTimeSlotView
        self.view.addSubview(addButton)
        self.addButton.snp.makeConstraints { make in
            make.height.equalTo(320)
            make.left.equalTo(self.view.snp.left)
            make.width.equalTo(self.view.snp.width)
            make.bottom.equalTo(self.view.snp.bottom)
        }
        
        self.launchAnim = LaunchAnimationView(frame: view.frame)
        self.view.addSubview(launchAnim!)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let currentDay = Calendar.current.component(.day, from: Date())
        calendarLabel?.setTitle(String(format: "%02d", currentDay), for: .normal)
        
        disposeBag = disposeBag ?? DisposeBag()
        
        //TODO: Inject this instead
        AppDelegate.instance
            .isEditingObservable
            .subscribe(onNext: onEditChanged)
            .addDisposableTo(disposeBag!)
        
        addButton
            .categoryObservable
            .subscribe(onNext: onNewCategory)
            .addDisposableTo(disposeBag!)
        
        pagerViewController
            .dateObservable
            .subscribe(onNext: onDateChanged)
            .addDisposableTo(disposeBag!)
        
        // small delay to give launch screen time to fade away
        Timer.schedule(withDelay: 0.1) { _ in
            self.launchAnim?.animate(onCompleted:
                {
                    self.launchAnim!.removeFromSuperview()
                    self.launchAnim = nil
                }
            )
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        disposeBag = nil
        super.viewWillDisappear(animated)
    }
    
    // MARK: Actions
    @IBAction func onCalendarTouchUpInside()
    {
        let today = Date().ignoreTimeComponents()
        
        guard viewModel.currentDate.ignoreTimeComponents() != today else { return }
        
        pagerViewController.setViewControllers(
            [ TimelineViewController(date: today) ],
            direction: .forward,
            animated: true,
            completion: nil)
        
        onDateChanged(date: today)
    }
    
    @IBAction func onSendLogButtonTouchUpInside()
    {   
        guard MFMailComposeViewController.canSendMail() else
        {
            return showAlert(withTitle: "Something went wrong :(", message: "You need to set up an email account before sending emails.")
        }
        
        guard let baseURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else
        {
            return showAlert(withTitle: "Something went wrong :(", message: "We are unable to find the log file.")
        }
        
        let fileURL = baseURL.appendingPathComponent("swiftybeaver.log", isDirectory: false)
        
        guard let fileData = try? Data(contentsOf: fileURL) else
        {
            return showAlert(withTitle: "Something went wrong :(", message: "We are unable to find the log file.")
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
        debugView.isHidden = !debugView.isHidden
    }
    
    // MARK: MFMailComposeViewControllerDelegate implementation
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Methods
    private func onDateChanged(date: Date)
    {
        viewModel.currentDate = date
        titleLabel.text = viewModel.title
        
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
    
    private func onNewCategory(category: Category)
    {
        viewModel.addNewSlot(withCategory: category)
    }
    
    private func onEditChanged(_ isEditing: Bool)
    {
        let alpha = isEditing ? Constants.editingAlpha : 1
        
        icon.alpha = alpha
        logButton.alpha = alpha
        titleLabel.alpha = alpha
        
        logButton.isUserInteractionEnabled = !isEditing
        calendarLabel.isUserInteractionEnabled = !isEditing
        
        addButton.close()
    }
    
    func showAlert(withTitle title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
