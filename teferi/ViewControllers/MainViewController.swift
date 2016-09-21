import UIKit
import CoreLocation
import RxSwift
import CoreMotion
import MessageUI

class MainViewController : UIViewController, MFMailComposeViewControllerDelegate
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
    
    @IBOutlet private weak var titleLabel : UILabel!
    
    // MARK: UIViewController lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        pagerViewController.onDateChanged = onDateChanged
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        disposeBag = nil
        super.viewWillDisappear(animated)
    }
    
    // MARK: Actions
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
    
    func showAlert(withTitle title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}




















