import UIKit
import CoreLocation
import RxSwift
import CoreMotion
import MessageUI

class MainViewController : UIViewController, MFMailComposeViewControllerDelegate
{
    // MARK: Fields
    private let viewModel : MainViewModel = MainViewModel()
    private var disposeBag : DisposeBag? = DisposeBag()
    private var pagerViewController : PagerViewController
    {
        return self.childViewControllers.last as! PagerViewController
    }
    
    @IBOutlet private weak var icon : UIImageView!
    @IBOutlet private weak var logButton : UIButton!
    private var launchAnim : LaunchAnimationView?
    
    @IBOutlet private weak var titleLabel : UILabel!
    @IBOutlet private weak var debugView : DebugView!
    @IBOutlet private weak var calendarLabel : UIButton!
    
    // MARK: UIViewController lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        pagerViewController.onDateChanged = onDateChanged
        
        debugView.isHidden = true
        AppDelegate.instance.locationService.subscribeToLocationChanges(debugView.onNewLocation)
        
        launchAnim = LaunchAnimationView(frame: view.frame)
        view.addSubview(launchAnim!)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let currentDay = Calendar.current.component(.day, from: Date())
        
        calendarLabel?.setTitle(String(format: "%02d", currentDay), for: .normal)
        pagerViewController.onDateChanged = onDateChanged
        
        if disposeBag == nil
        {
            disposeBag = DisposeBag()
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate
            .isEditingObservable
            .subscribe(onNext: onEditChanged)
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
        
        onDateChanged(today)
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
    private func onDateChanged(_ date: Date)
    {
        viewModel.currentDate = date
        titleLabel.text = viewModel.title
    }
    
    private func onEditChanged(_ isEditing: Bool)
    {
        let alpha = isEditing ? Constants.editingAlpha : 1
        
        icon.alpha = alpha
        logButton.alpha = alpha
        titleLabel.alpha = alpha
        
        logButton.isUserInteractionEnabled = !isEditing
        calendarLabel.isUserInteractionEnabled = !isEditing
    }
    
    func showAlert(withTitle title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
